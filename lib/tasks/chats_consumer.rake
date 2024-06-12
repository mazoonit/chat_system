#!/usr/bin/env ruby
require 'bunny'

namespace :consumers do
    task :chats_consumer => :environment do
        connection = Bunny.new(ENV.fetch("RABBITMQ_URL"))
        connection.start
        channel = connection.create_channel
        queue = channel.queue("chats", durable: true, manual_ack: true)

        begin
            puts ' [*] Waiting for messages. To exit press CTRL+C'
            queue.subscribe(manual_ack: true, block: true) do |delivery_info, properties, body|
            chat = JSON.parse(body, object_class: Chat)
            if chat.save
                $redis.sadd("updated_applications", chat.application_id)
                channel.ack(delivery_info.delivery_tag)
                puts " [x] Consumed #{body}"
            end
            end
        rescue Interrupt => _
            channel.close
            connection.close
            exit(0)
        end
    end
end