desc "Daily cron job to clean up obsoleted pictures"
task :cron => :environment do
  Photo.obsoleted.each { |p| p.destroy }
end