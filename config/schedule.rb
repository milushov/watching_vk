 set :output, "#{path}/log/cron_log.log"

 every 1.minute do
  command "curl localhost:9292/check/$WATCHING_VK_PASSWORD"
 end


