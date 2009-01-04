set :rails_env, "production"

set :domain, "#{rails_env}.billedid.gzb.dk"

# Modify these values to execute tasks on a different server.
role :web, domain
role :app, domain
role :db,  domain, :primary => true
role :scm, domain

set :apache_server_name, domain
set :apache_server_aliases, %w{production.billedid.dk billedid.dk www.billedid.dk}

set :keep_releases, 3
