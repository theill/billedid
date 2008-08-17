# this script *only* works on RailsMachine setups

# default values you might want to change
DEVELOPMENT_SOURCE = 'staging'
STAGING_SOURCE = 'development'
PRODUCTION_SOURCE = 'development' # this should only be used initially

# configure these for each customer
STAGING_DOMAIN = 'billedid.gzb.dk'
PRODUCTION_DOMAIN = 'production.billedid.gzb.dk'
DEPLOY_TO = 'billedid'

namespace :gazebo do
  namespace :db do
    desc "Copy entire database into current environment"
    task :load => :environment do
      db_config = ActiveRecord::Base.configurations[RAILS_ENV]
      
      puts "Copying database"
      case RAILS_ENV
      when 'development'
        db_config_source = ActiveRecord::Base.configurations[DEVELOPMENT_SOURCE]
        sh %{ssh -l deploy -C #{STAGING_DOMAIN} mysqldump -u #{db_config_source['username']} --password=#{db_config_source['password']} #{db_config_source['database']} | mysql -u root #{db_config['database']}}
        
      when 'staging'
        db_config_source = ActiveRecord::Base.configurations[STAGING_SOURCE]
        sh %{mysqldump -u root #{db_config_source['database']} | ssh -C deploy@#{STAGING_DOMAIN} mysql -u #{db_config['username']} --password=#{db_config['password']} #{db_config['database']}}
        
      when 'production'
        db_config_source = ActiveRecord::Base.configurations[PRODUCTION_SOURCE]
        sh %{mysqldump -u root #{db_config_source['database']} | ssh -C deploy@#{PRODUCTION_DOMAIN} mysql -u #{db_config['username']} --password=#{db_config['password']} #{db_config['database']}}
        
      else
        puts "Environment #{RAILS_ENV} is not supported by this rake script"
      end
    end
    
    desc "Copy all assets into current environment"
    task :assets do
      puts "Copying assets"
      
      case RAILS_ENV
      when 'development'
        sh %{rsync -e 'ssh' -a deploy@#{STAGING_DOMAIN}:/var/www/apps/#{DEPLOY_TO}/shared/public/assets/ public/assets/ --progress}
        
      when 'staging'
        sh %{rsync -e 'ssh' -a public/assets/ deploy@#{STAGING_DOMAIN}:/var/www/apps/#{DEPLOY_TO}/shared/public/assets/ --progress}
        
      when 'production'
        sh %{rsync -e 'ssh' -a public/assets/ deploy@#{PRODUCTION_DOMAIN}:/var/www/apps/#{DEPLOY_TO}/shared/public/assets/ --progress}
        
      else
        puts "Environment #{RAILS_ENV} is not supported by this rake script"
      end
    end
  end
end