task :update_counters => :environment do
    # get updated apps from redis set
    updated_applications = $redis.smembers('updated_applications')
    updated_applications.each do |application_id|
        # updating the count with the presisted data in db.
        count = Chat.where(application_id: application_id).count
        application = Application.find_by(id: application_id)
        application.chats_count = count
        application.save
    end

    # get updated chats from redis set
    updated_chats = $redis.smembers('updated_chats')
    updated_chats.each do |chat_id|
        # updating the count with the presisted data in db.
        count = Message.where(chat_id: chat_id).count
        chat = Chat.find_by(id: chat_id)
        chat.messages_count = count
        chat.save
    end
end