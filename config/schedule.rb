# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, "#{path}/log/fechas_eventos.log" # Apunta a log/fechas_eventos.log
#set :environment, 'development' # Comentar esta línea deja automáticamente en production

#every 3.minutes do
#  runner "Evento::actualizar_estatus"
#end

every :day, :at => '12:20am' do #Según timezone del servidor puede requerir ajustar las horas
    runner "Evento::actualizar_estatus", :environment => 'development'
    runner "Evento::actualizar_estatus", :environment => 'production'
end