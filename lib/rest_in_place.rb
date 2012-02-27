require "rest_in_place/version"

module RestInPlace
  class Engine < Rails::Engine
    # no ruby code here!
  end
  
  def self.include_root_in_json?
    if defined?(Mongoid)
      Mongoid.config.include_root_in_json
    elsif defined?(ActiveRecord)
      ActiveRecord::Base.include_root_in_json
    else
      false
    end
  end
end
