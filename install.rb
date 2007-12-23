# Install hook code here
puts "Copying files..."
dest_file = File.join(RAILS_ROOT, "public", "javascripts", "rest_in_place.js")
src_file = File.join(File.dirname(__FILE__) , "javascripts", "rest_in_place.js")
FileUtils.cp_r(src_file, dest_file)
puts "Files copied - Installation complete!"