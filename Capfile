load 'deploy' if respond_to?(:namespace) # cap2 differentiator

# standard settings
set :app_file, "application.rb"
set :application, "oyekids"
set :app_class, ""
set :domain, "oyekids.com"
role :app, domain
role :web, domain
# role :db,  domain, :primary => true

# environment settings
set :deploy_to, "/var/www/#{domain}"
set :deploy_via, :remote_cache
default_run_options[:pty] = true

# scm settings
set :ssh_options, { :forward_agent => true }
set :repository, "git://github.com/philoye/oyekids.git"
set :scm, "git"
set :branch, "master"
set :git_shallow_clone, 1
set :scm_verbose, true
set :use_sudo, false


namespace :deploy do
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end