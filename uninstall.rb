# Uninstall hook code here
puts "Deleting files..."
dir = "javascripts"
%w[jquery.rest_in_place.js mootools.rest_in_place.js rest_in_place.js].each do |js_file|
  dest_file = if (Rails::VERSION::STRING.to_f >= '3.1.0'.to_f)
              	File.join(::Rails.root, "vendor", "assets", dir, js_file)
              else
                File.join(::Rails.root, "public", dir, js_file)
              end
  FileUtils.rm(dest_file)
end
puts "Files deleted - Uninstallation complete!"
