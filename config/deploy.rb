require 'bundler/capistrano' # for bundler support
require 'sidekiq/capistrano'
# require 'whenever/capistrano'

load "deploy/assets"

set :application, "view_finder"
set :repository,  "git@github.com:eewang/view_finder.git"

set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

default_run_options[:pty] = true


set :user, 'flatiron'
set :deploy_to, "/home/#{user}/#{application}"
set :use_sudo, false

default_run_options[:pty] = true

role :web, "198.199.67.119"                          # Your HTTP server, Apache/etc
role :app, "198.199.67.119"                          # This may be the same as your `Web` server
role :db,  "198.199.67.119", :primary => true # This is where Rails migrations will run


# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"
before "deploy:assets:precompile", "deploy:symlink_configs"
# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :symlink_configs, :roles => :app do
    run "ln -nfs #{shared_path}/production.sqlite3 #{release_path}/db/production.sqlite3"
    run "ln -nfs #{shared_path}/application.yml #{release_path}/config/application.yml"
    
    # run "ln -nfs #{shared_path}/database.yml #{release_path}/config"
    # run "ln -nfs #{shared_path}/api_keys.yml #{release_path}/config"
  end

end

task :copy_application_yml, :roles => :app do
  upload("config/application.yml", "#{shared_path}/application.yml")
end

desc "tail production log files" 
task :tail_logs, :roles => :app do
  trap("INT") { puts 'Interupted'; exit 0; }
  run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
    puts  # for an extra line break before the host name
    puts "#{channel[:host]}: #{data}" 
    break if stream == :err
  end
end
