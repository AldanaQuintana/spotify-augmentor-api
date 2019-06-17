require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
require 'foreman'

set :domain, ''
set :deploy_to, '/var/www/spotify-augmentor'
set :user, 'ubuntu'
set :repository, 'git@github.com:AldanaQuintana/spotify-augmentor-api.git'
set :branch, 'master'
set :env_config, File.open('./.env')

set :shared_paths, ['tmp/server', 'log', '.rbenv-vars']

set :forward_agent, true     # SSH forward_agent.

task :environment do
  invoke :'rbenv:load'
end

task :copy_env_config => :environment do
  queue('echo "-----> Configuring environment"')
  queue("echo \"\" > #{deploy_to}/#{shared_path}/.env")
  env_config.each_line do |line|
    queue("echo \"#{line.strip}\" >> #{deploy_to}/#{shared_path}/.env")
  end
  queue("echo \"PATH=$(bundle show bundler):$PATH\" >> #{deploy_to}/#{shared_path}/.env")
  queue("echo \"ENVIRONMENT=production\" >> #{deploy_to}/#{shared_path}/.env")
end

task :setup => :environment do
  queue("ln -sTf #{deploy_to}/#{current_path} /var/www/app")
  queue("mkdir -p #{deploy_to}/#{shared_path}/log")
end

task :export_foreman_jobs => :environment do
  queue("cd #{deploy_to}/#{current_path} && sudo -E env \"PATH=$PATH\" foreman export upstart /etc/init -a queue -e #{deploy_to}/#{shared_path}/.env")
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
    invoke :'copy_env_config'

    to :launch do
      invoke :'export_foreman_jobs'
      invoke :'server:restart'
      invoke :'server:restart_queue'
    end
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

  task :restart_queue => :environment do
    queue %Q%
      sudo start queue || sudo restart queue
    %
  end
end
