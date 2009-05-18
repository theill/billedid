set :rails_env, "production"

set :domain, "billedid.dk.rails.it-kartellet.dk"

role :web, domain
role :app, domain
role :db,  domain, :primary => true
role :scm, domain

set :application, "billedid.dk"

set :use_sudo, false
set :deploy_to, "/home/peter/rails/#{application}"

set :user, "peter"
set :runner, "peter"
set :admin_runner, "peter"
