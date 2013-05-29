 set :output, "#{path}/log/cron_log.log"

 every 10.minute do
  command "curl http://watching-vk.milushov.ru/check"
 end


