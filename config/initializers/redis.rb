require 'redis'
begin
    $redis = Redis.new(url: ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" })
    $redlock = Redlock::Client.new([ENV.fetch("REDIS_URL")])
rescue Exception => e
    puts e
end
