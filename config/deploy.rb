#require 'bundler/capistrano'

set :user, "deploy"
set :application, "hfc"
set :repository,  "git@github.com:zsimpson/hfc_ruby.git"
set :scm, "git"
set :deploy_to, "/webapps/hfc"

role :web, "ideasfreetogoodhome.org"
role :app, "ideasfreetogoodhome.org"
role :db,  "ideasfreetogoodhome.org", :primary => true

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
   task :start do ; end
   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "touch #{File.join(current_path,'tmp','restart.txt')}"
   end
end

after 'deploy:update_code', 'deploy:symlink_db'
namespace :deploy do
  desc "Symlinks the database.yml"
  task :symlink_db, :roles => :app do
    run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
  end
end

