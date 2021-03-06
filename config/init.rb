# Go to http://wiki.merbivore.com/pages/init-rb
# Specify a specific version of a dependency
# 

def is19?
  defined?(Encoding)
end

if is19?
  Encoding.default_internal = Encoding.default_external = "UTF-8"
else
  require Merb.root / 'merb' / 'monkey' / 'ruby19_compat'
end

require 'cgi'

use_test :rspec
use_template_engine :haml
 
Merb::Config.use do |c|
  c[:use_mutex] = false
  c[:session_store] = 'cookie'  # can also be 'memory', 'memcache', 'container', 'datamapper
  
  # cookie session store configuration
  c[:session_secret_key]  = 'ff0bc97fd0e7d3a1e9f62389270643c91d0991ec'  # required for cookie session store
  c[:fork_for_class_load] = false
end

Merb::BootLoader.before_app_loads do
  Merb.push_path(:merb_extensions, Merb.root / "merb/extensions", "**/*.rb")  
  Merb.push_path(:lib, Merb.root / "lib", "**/*.rb")
  require Merb.root / 'lib' / 'object.rb'
  require 'moneta'
  require 'moneta/memcache'
end
 
Merb::BootLoader.after_app_loads do
  # This will get executed after your app's classes have been loaded.
  begin    
    Wikipedia.settings = YAML::load(open("config/wikipedias.yml"))
    Languages = {}
    Dir.glob("config/translations/**.yml").each do |file|
      code = file.split("/").last.split(".").first
      Languages[code] = YAML::load(open(file))
    end
    Device.available_formats = YAML::load(open("config/formats.yml"))
  rescue Exception => e
    puts "There appears to be a syntax error in your YAML configuration files."
    exit
  end
  
  unless defined?(Cache)
    if Merb.env == "production"
      Cache = Moneta::Memcache.new(:server => "127.0.0.1")
    else
      require 'moneta/memory'
      Cache = Moneta::Memory.new
    end
  end
  
  # This is a UNIX signal that can be sent to restart the logger
  trap("USR1") do
    Merb.logger.flush
    Merb::Config[:log_stream].close
    Merb::BootLoader::Dependencies.update_logger
  end
end

# Add our mime-types for device based content type negotiation
%w[webkit_native webkit].each do |type|
  Merb.add_mime_type(:"#{type}", :to_html, %w[text/html])
end
Merb.add_mime_type(:wml, :to_wml, %w[text/vnd.wap.wml])
