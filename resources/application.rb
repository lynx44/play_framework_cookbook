actions :deploy, :start, :stop
default_action :start

attribute :name, :kind_of => String, :name_attribute => true
attribute :install_path, :kind_of => String
attribute :package_url, :kind_of => String
attribute :port, :kind_of => Integer, :default => 9000
attribute :arguments, :kind_of => Hash, :default => {}