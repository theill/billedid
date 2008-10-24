namespace :gazebo do
  desc "Clean up existing photos"
  task :photos => :environment do
    Photo.obsoleted.delete_all
  end
end