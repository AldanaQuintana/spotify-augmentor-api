require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)

if ENV['RACK_ENV'] == 'production'
  set :domain, ''
  set :deploy_to, ''
  set :user, ''
else
  set :domain, ''
  set :deploy_to, ''
  set :user, ''
end

set :repository, ''
set :branch, 'master'

set :shared_paths, ['tmp/server', 'log', '.rbenv-vars']

set :forward_agent, true     # SSH forward_agent.

task :environment do
  invoke :'rbenv:load'
end

task :setup => :environment do
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  to :before_hook do
  end

  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'deploy:cleanup'
  end
end

namespace :server do
  set :puma_state, -> {"#{deploy_to}/#{shared_path}/tmp/server/state"}
  set :puma_config, -> { "#{deploy_to}/#{current_path}/config/puma.rb" }

  task :stop => :environment do
    queue %Q%
      cd #{deploy_to}/#{current_path}
      echo "-----> Calling puma stop"
      bundle exec pumactl -S "#{puma_state}" stop
    %
  end

  task :start => :environment do
    queue %Q%
      cd #{deploy_to}/#{current_path}
      echo "-----> Calling puma start"
      bundle exec puma -C #{puma_config}
    %
  end

  task :restart => :environment do
    invoke :'server:stop'
    invoke :'server:start'
  end

end
