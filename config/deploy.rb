require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rvm'

set :domain, '159.89.194.107'
set :deploy_to, '/var/www/spotify-augmentor'
set :user, 'spotty'
set :repository, 'git@github.com:AldanaQuintana/spotify-augmentor-api.git'
set :branch, 'master'
set :env_config, File.open('./.env')

set :shared_paths, ['tmp/server', 'log']

set :forward_agent, true     # SSH forward_agent.

task :environment do
  invoke :'rvm:use[ruby-2.6.3@default]'
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

desc "Deploys the current version to the server."
task :deploy => :environment do
  to :before_hook do
  end

  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'copy_env_config'
    invoke :'deploy:cleanup'

    to :launch do
      invoke :'server:restart'
      invoke :'server:restart_queue'
    end
  end
end

namespace :server do
  task :stop => :environment do
    queue %Q%
      sudo service nginx stop
    %
  end

  task :start => :environment do
    queue %Q%
      sudo service nginx start
    %
  end

  task :restart => :environment do
    queue %Q%
      sudo service nginx restart
    %
  end

  task :restart_queue => :environment do
    queue %Q%
      sudo start queue || sudo restart queue
    %
  end
end
