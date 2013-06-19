 set :output, "#{path}/log/cron_log.log"

 every 10.minute do
  command "curl localhost:9292/check"
 end
