class ChatService
    def self.get_chat_id(application_token, application_id, chat_number)
        key = "#{application_token}_#{chat_number}"
        if (chat_id = $redis.get(key))
            chat_id
        else
            chat = Chat.find_by!(application_id: application_id, number: chat_number)
            $redis.set(key, chat.id)
            chat.id
        end
    rescue => e
        Rails.logger.error("Error getting chat id: #{e.message}")
        nil
    end

    def self.get_new_message_number(application_token, application_id, chat_id)
        key = "#{application_token}_#{chat_id}_messages_count" 
        if $redis.exists?(key)
            new_message_number = $redis.incr(key) # It's atomic, so It's immune to race conditions.
        else
            begin
            # lock the queue, It happens first time only.
                $redlock.lock!("#{key}_lock", 2000) do
                    messages_inqueue_max_number = $redis.get(key).to_i # Try to get the key one more time inside the lock, just in case we were waiting another instance.
                    messages_db_max_number = Message.where(chat_id: chat_id).maximum(:number).to_i

                    # Since, we can't rely on db's max If there's data already is in the queue.
                    # I made sure that redis data is presistant not volatile.
                    # so in theory there's no way to have data in queue not logged in redis.

                    new_message_number = [messages_inqueue_max_number, messages_db_max_number].max + 1
                    
                    $redis.set(key, new_message_number)
                end
            rescue Redlock::LockError => e
                puts e
                return nil
            end
        end
        new_message_number.to_i
    rescue => e
        Rails.logger.error("Error retrieving new message number: #{e.message}")
        nil
    end
end