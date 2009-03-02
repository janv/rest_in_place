namespace :rest_in_place do
  
  desc "Creates a sample record for use in testing. (User)"
  task :create_sample => :environment do
    User.create! :name => "Frank"
    p "Created test record."
  end
  
end