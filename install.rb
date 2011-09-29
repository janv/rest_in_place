# Install hook code here
puts "Copying files..."
dir = "javascripts"
%w[jquery.rest_in_place.js mootools.rest_in_place.js rest_in_place.js].each do |js_file|
  dest_file = if (Rails::VERSION::STRING.to_f >= '3.1.0'.to_f)
                File.join(::Rails.root, "vendor", "assets", dir, js_file)
              else
                File.join(::Rails.root, "public", dir, js_file)
              end
  src_file = File.join(File.dirname(__FILE__) , dir, js_file)
  FileUtils.cp_r(src_file, dest_file)
end
puts "Files copied - Installation complete!"
