# Uninstall hook code here
puts "Deleting files..."
dest_file = File.join(RAILS_ROOT, "public", "javascripts", "rest_in_place.js")
FileUtils.rm(dest_file)
puts "Files deleted - Uninstallation complete!"