 set :output, "#{path}/log/cron_log.log"

 every 1.minute do
  command "curl http://watching-vk.milushov.ru/check/$WATCHING_VK_PASSWORD"
 end


