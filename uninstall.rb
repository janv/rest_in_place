# Uninstall hook code here
puts "Deleting files..."
dir       = "javascripts"
file      = "jquery.rest_in_place.js"
dest_file = if (Rails::VERSION::STRING.to_f >= '3.1.0'.to_f)
              File.join(::Rails.root, "vendor", "assets", dir, file)
            else
              File.join(::Rails.root, "public", dir, file)
            end
FileUtils.rm(dest_file)
puts "Files deleted - Uninstallation complete!"
