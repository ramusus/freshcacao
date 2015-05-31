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