set :rails_env, "production"

set :mongrel_environment, rails_env

set :domain, "#{rails_env}.billedid.gzb.dk"

# Modify these values to execute tasks on a different server.
role :web, domain
role :app, domain
role :db,  domain, :primary => true
role :scm, domain

set :apache_server_name, domain

set :apache_server_aliases, %w{production.billedid.dk billedid.dk www.billedid.dk}
set :apache_proxy_port, X

set :mongrel_port, apache_proxy_port

set :keep_releases, 3
