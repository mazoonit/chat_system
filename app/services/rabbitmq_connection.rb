class RabbitmqConnection
    include Singleton
    def initialize
        establish_connection
    end
    
    def establish_connection
        @active_connection = Bunny.new(ENV.fetch("RABBITMQ_URL"))
        @active_connection.start
        @active_channel = @active_connection.create_channel

        @active_connection      
    end

    def connection
        return @active_connection if connected?
        establish_connection
      
        @active_connection
      end
      
    def channel
        return @active_channel if connected? && @active_channel&.open?
        establish_connection
        
        @active_channel
    end
    
    def connected?
        @active_connection&.connected?
    end

    def close
        @active_connection.close
    end
end