# Install hook code here
puts "Copying files..."
dir       = "javascripts"
file      = "jquery.rest_in_place.js"
dest_file = if (Rails::VERSION::STRING.to_f >= '3.1.0'.to_f)
              File.join(::Rails.root, "vendor", "assets", dir, file)
            else
              File.join(::Rails.root, "public", dir, file)
            end
src_file  = File.join(File.dirname(__FILE__) , dir, file)
FileUtils.cp_r(src_file, dest_file)
puts "Files copied - Installation complete!"
