#!/usr/bin/env ruby
require 'bunny'

task :consumer => :environment do
    connection = Bunny.new("amqp://guest:Guest1234@rabbitmq:5672")
    connection.start
    channel = connection.create_channel
    queue = channel.queue("chats", durable: true, manual_ack: true)

    begin
        puts ' [*] Waiting for messages. To exit press CTRL+C'
        queue.subscribe(manual_ack: true, block: true) do |delivery_info, properties, body|
        chat = JSON.parse(body, object_class: Chat)
        chat.save
        channel.ack(delivery_info.delivery_tag)
        puts " [x] Consumed #{body}"
        end
    rescue Interrupt => _
        channel.close
        connection.close
        exit(0)
    end
end
