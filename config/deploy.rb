require 'railsmachine/recipes'

set :stages, %w(staging production)
set :default_stage, 'staging'

# This defines a deployment "recipe" that you can feed to capistrano
# (http://manuals.rubyonrails.com/read/book/17). It allows you to automate
# (among other things) the deployment of your application.

# =============================================================================
# REQUIRED VARIABLES
# =============================================================================
# You must always specify the application and repository for every recipe. The
# repository must be the URL of the repository you want this recipe to
# correspond to. The deploy_to path must be the path on each machine that will
# form the root of the application path.

# The name of your application. Used for directory and file names associated with
# the application.
set :application, "billedid"

# Target directory for the application on the web and app servers.
set :deploy_to, "/var/www/apps/#{application}"

# Login user for ssh.
set :user, "deploy"
set :runner, "deploy"

set :scm, :git
set :repository, "git@github.com:theill/weight.git"
set :branch, "master"
set :repository_cache, "git_cache"
#currently fails on cap 2.3.0  set :deploy_via, :remote_cache
set :ssh_options, { :forward_agent => true }

# Automatically symlink these directories from curent/public to shared/public.
# set :app_symlinks, %w{photo document asset}

# =============================================================================
# APACHE OPTIONS
# =============================================================================
# set :apache_server_name, domain
# set :apache_server_aliases, %w{alias1 alias2}
# set :apache_default_vhost, true # force use of apache_default_vhost_config
# set :apache_default_vhost_conf, "/etc/httpd/conf/default.conf"
# set :apache_conf, "/etc/httpd/conf/apps/#{application}.conf"
# set :apache_ctl, "/etc/init.d/httpd"
# set :apache_proxy_address, "127.0.0.1"
# set :apache_ssl_enabled, false
# set :apache_ssl_ip, "127.0.0.1"
# set :apache_ssl_forward_all, false

# =============================================================================
# MONGREL OPTIONS
# =============================================================================
# set :mongrel_servers, apache_proxy_servers
# set :mongrel_port, apache_proxy_port
# set :mongrel_address, apache_proxy_address
# set :mongrel_environment, "production"
# set :mongrel_pid_file, "/var/run/mongrel_cluster/#{application}.pid"
# set :mongrel_conf, "/etc/mongrel_cluster/#{application}.conf"
# set :mongrel_user, user
# set :mongrel_group, group

# =============================================================================
# SCM OPTIONS
# =============================================================================
#set :scm,"subversion"

# =============================================================================
# SSH OPTIONS
# =============================================================================
# ssh_options[:keys] = %w(/path/to/my/key /path/to/another/key)
# ssh_options[:port] = 25

# =============================================================================
# CAPISTRANO OPTIONS
# =============================================================================
# default_run_options[:pty] = true
set :keep_releases, 3

require 'capistrano/ext/multistage'