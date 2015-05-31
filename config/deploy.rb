# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'fc_new'
set :repo_url, 'git@github.com:ramusus/freshcacao.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/home/hosting_abbb/projects/fc_new'

set :rvm_ruby_version, '2.2.0'

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
        run "if [ -f #{fetch(:unicorn_pid)} ] && [ -e /proc/$(cat #{fetch(:unicorn_pid)}) ]; then kill -USR2 `cat #{fetch(:unicorn_pid)}`; else cd #{deploy_to}/current && bundle exec unicorn -c #{fetch(:unicorn_conf)} -E #{fetch(:rails_env)} -D; fi"
    end
  end
  # task :start do
  #   run "bundle exec unicorn -c #{unicorn_conf} -E #{rails_env} -D"
  # end
  # task :stop do
  #   run "if [ -f #{fetch(:unicorn_pid)} ] && [ -e /proc/$(cat #{fetch(:unicorn_pid)}) ]; then kill -QUIT `cat #{fetch(:unicorn_pid)}`; fi"
  # end
  # task :restart, :roles => :app, :except => { :no_release => true } do
  #   run "if [ -f #{fetch(:unicorn_pid)} ] && [ -e /proc/$(cat #{fetch(:unicorn_pid)}) ]; then kill -USR2 `cat #{fetch(:unicorn_pid)}`; else cd #{deploy_to}/current && bundle exec unicorn -c #{unicorn_conf} -E #{rails_env} -D; fi"
  # end
  # task :auto_migrate do
  #   rake = fetch(:rake, "rake")
  #   rails_env = fetch(:rails_env, "production")
  #   run "cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} db:auto:migrate"
  # end
end

# from here https://gist.github.com/2016396
# namespace :deploy do
#   desc "Push local changes to Git repository"
#   task :push do
#     # Check for any local changes that haven't been committed
#     # Use 'cap deploy:push IGNORE_DEPLOY_RB=1' to ignore changes to this file (for testing)
#     #    status = %x(git status --porcelain).chomp
#     #    if status != ""
#     #      if status !~ %r{^[M ][M ] config/deploy.rb$}
#     #        raise Capistrano::Error, "Local git repository has uncommitted changes"
#     #      elsif !ENV["IGNORE_DEPLOY_RB"]
#     #        # This is used for testing changes to this script without committing them first
#     #        raise Capistrano::Error, "Local git repository has uncommitted changes (set IGNORE_DEPLOY_RB=1 to ignore changes to deploy.rb)"
#     #      end
#     #    end
#
#     # Check we are on the master branch, so we can't forget to merge before deploying
#     branch = %x(git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \\(.*\\)/\\1/').chomp
#     if branch != "master" && !ENV["IGNORE_BRANCH"]
#       raise Capistrano::Error, "Not on master branch (set IGNORE_BRANCH=1 to ignore)"
#     end
#
#     # Push the changes
#     if ! system "git push #{fetch(:repository)} master"
#       raise Capistrano::Error, "Failed to push changes to #{fetch(:repository)}"
#     end
#
#   end
# end

# if !ENV["NO_PUSH"]
#   before "deploy", "deploy:push"
#   before "deploy:migrations", "deploy:push"
# end