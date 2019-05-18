root = "#{Dir.getwd}"
bind "unix://#{root}/tmp/server/socket"
pidfile "#{root}/tmp/server/pid"
state_path "#{root}/tmp/server/state"
stdout_redirect "#{root}/log/stdout.log", "#{root}/log/stderr.log", true

daemonize ENV['DAEMONIZE'] == 'false' ? false : true

port ENV['PORT'] || 3000

environment ENV['RACK_ENV']

rackup DefaultRackup

threads 4, 8