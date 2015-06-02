# config valid only for current version of Capistrano
lock '3.4.0'

set :application,       'fc-new'
set :rvm_ruby_version,  '2.2.0'
set :user,              'hosting_abbb'
set :login,             'abbb'
set :use_sudo,          false
set :repo_url,          'git@github.com:ramusus/freshcacao.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/#{fetch(:user)}/projects/#{fetch(:application)}"

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

set :unicorn_conf,      "/etc/unicorn/#{fetch(:application)}.#{fetch(:login)}.rb"
set :unicorn_pid,       "/var/run/unicorn/#{fetch(:user)}/#{fetch(:application)}.#{fetch(:login)}.pid"
set :unicorn_start_cmd, "(cd #{fetch(:deploy_to)}/current; rvm use #{fetch(:rvm_ruby_version)} do bundle exec unicorn_rails -Dc #{fetch(:unicorn_conf)})"

namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      execute "[ -f #{fetch(:unicorn_pid)} ] && kill -USR2 `cat #{fetch(:unicorn_pid)}` || #{fetch(:unicorn_start_cmd)}"
    end
  end

  desc 'Start application'
  task :start do
    on roles(:web), in: :groups, wait: 5 do
      execute "#{fetch(:unicorn_start_cmd)}"
    end
  end

  desc "Stop application"
  task :stop do
    on roles(:web), in: :groups, wait: 5 do
      execute "[ -f #{fetch(:unicorn_pid)} ] && kill -QUIT `cat #{fetch(:unicorn_pid)}`"
    end
  end
end

# from here https://gist.github.com/2016396
namespace :deploy do
  desc "Push local changes to Git repository"
  task :push do
    # Check for any local changes that haven't been committed
    # Use 'cap deploy:push IGNORE_DEPLOY_RB=1' to ignore changes to this file (for testing)
    #    status = %x(git status --porcelain).chomp
    #    if status != ""
    #      if status !~ %r{^[M ][M ] config/deploy.rb$}
    #        raise Capistrano::Error, "Local git repository has uncommitted changes"
    #      elsif !ENV["IGNORE_DEPLOY_RB"]
    #        # This is used for testing changes to this script without committing them first
    #        raise Capistrano::Error, "Local git repository has uncommitted changes (set IGNORE_DEPLOY_RB=1 to ignore changes to deploy.rb)"
    #      end
    #    end

    # Check we are on the master branch, so we can't forget to merge before deploying
    branch = %x(git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \\(.*\\)/\\1/').chomp
    if branch != "master" && !ENV["IGNORE_BRANCH"]
      raise RuntimeError, "Not on master branch (set IGNORE_BRANCH=1 to ignore)"
    end

    # Push the changes
    if ! system "git push #{fetch(:repo_url)} master"
      raise RuntimeError, "Failed to push changes to #{fetch(:repo_url)}"
    end

  end
end

if !ENV["NO_PUSH"]
  before "deploy", "deploy:push"
  # before "deploy:migrations", "deploy:push"
end