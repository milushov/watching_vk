 set :output, "#{path}/log/cron_log.log"

 every 1.hours do
  command "/usr/bin/some_great_command"
 end


