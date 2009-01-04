set :rails_env, "staging"

set :domain, "#{rails_env}.billedid.gzb.dk"

role :web, domain
role :app, domain
role :db,  domain, :primary => true
role :scm, domain

set :apache_server_name, domain
set :apache_server_aliases, %w{billedid.gzb.dk staging.billedid.gzb.dk staging.billedid.dk billedid.dk www.billedid.dk staging.billedid.gazeboapps.com}

namespace :deploy do
  desc "Restart a passenger hosted RoR app"
  task :restart, :roles => :app do
  run <<-EOF
cd #{deploy_to}/current/tmp && touch #{deploy_to}/current/tmp/restart.txt
EOF
  end
end

# override mongrel tasks
namespace :mongrel do
  namespace :cluster do
    task :configure, :roles => :app do
      # do nothing
    end
    task :restart, :roles => :app do
      run "cd #{deploy_to}/current/tmp && touch #{deploy_to}/current/tmp/restart.txt"
    end
  end
end