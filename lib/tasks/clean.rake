namespace :gazebo do
  desc "Clean up existing photos"
  task :clean => :environment do
    Photo.obsoleted.each { |p| p.destroy }
  end
end