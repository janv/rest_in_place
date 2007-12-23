# Uninstall hook code here
puts "Deleting files..."
dir = "javascripts"
["jquery.rest_in_place.js", "rest_in_place.js"].each do |js_file|
  dest_file = File.join(RAILS_ROOT, "public", dir, js_file)
  FileUtils.rm(dest_file)
end
puts "Files deleted - Uninstallation complete!"