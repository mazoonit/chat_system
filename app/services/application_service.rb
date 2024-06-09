class ApplicationService
    def self.get_application_id_by_token(application_token)
        key = application_token
        if (app_id = $redis.get(key))
            app_id
        else
            app = Application.find_by!(token: application_token)
            $redis.set(key, app.id)
            app.id
        end
    rescue => e
        Rails.logger.error("Error getting application id: #{e.message}")
        nil
    end

    def self.get_new_chat_number(application_id, application_token)
        key = "#{application_token}_chats_count" 
        if $redis.exists?(key)
            new_chat_number = $redis.incr(key) # It's atomic, so It's immune to race conditions.
        else
            begin
            # lock the queue, It happens first time only.
                $redlock.lock!("#{key}_lock", 2000) do
                    chats_inqueue_max_number = $redis.get(key).to_i # Try to get the key one more time inside the lock, just in case we were waiting another instance.
                    chats_db_max_number = Chat.where(application_id: application_id).maximum(:number).to_i

                    # Since, we can't rely on db's max If there's data already is in the queue.
                    # I made sure that redis data is presistant not volatile.
                    # so in theory there's no way to have data in queue not logged in redis.

                    new_chat_number = [chats_inqueue_max_number, chats_db_max_number].max + 1
                    
                    $redis.set(key, new_chat_number)
                end
            rescue Redlock::LockError => e
                puts e
                return nil
            end
        end
        new_chat_number.to_i
    rescue => e
        Rails.logger.error("Error retrieving new chat number: #{e.message}")
        nil
    end
end