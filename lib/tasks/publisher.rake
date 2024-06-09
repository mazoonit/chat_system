#!/usr/bin/env ruby
require 'bunny'

task :publisher => :environment do
    connection = Bunny.new("amqp://guest:Guest1234@rabbitmq:5672")
    connection.start

    channel = connection.create_channel

    queue = channel.queue('hello')

    channel.default_exchange.publish('Hello World!', routing_key: queue.name)
    puts " [x] Sent 'Hello Worlddddddddddd!'"

    connection.close
end