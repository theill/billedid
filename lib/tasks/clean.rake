namespace :gazebo do
  desc "Clean up existing photos"
  task :clean => :environment do
    Photo.obsoleted.delete_all
  end
end