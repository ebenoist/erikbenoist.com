require "./initialize"
require "application"
require "bundler/capistrano"

#Values are set in config/application.yml
set :application, Application.config["application_name"]
set :domain,      Application.config["domain"]
set :repository,  Application.config["repository"]
set :deploy_to,   "/home/deploy/#{application}"
set :use_sudo,    false
set :scm,         "git"
set :user,        Application.config["deploy_user"]
set :deploy_via, :remote_cache
set :normalize_asset_timestamps, false
set :default_environment, {
    'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
}

role :app, domain
role :web, domain
role :db,  domain, :primary => true

after 'deploy:setup', 'deploy:upload_config' # upload config to shared
after 'deploy:create_symlink', 'deploy:link_config' # link the application.yml in shared

namespace :deploy do
  task :upload_config do
    application_config = File.read(Application.root + "/config/application.yml")
    run("mkdir -p #{shared_path}/config")
    put(application_config, "#{shared_path}/config/application.yml")
  end

  task :link_config do
    run("ln -nfs #{shared_path}/config/application.yml #{release_path}/config/application.yml")
  end

  task :force_restart do
  end

  task :start do
  end

  task :stop do
  end

  task :restart do
  end
end



