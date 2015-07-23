action :deploy do
  local_archive_path = "/var/tmp/#{project_name}.zip"
  package_url = @new_resource.package_url
  remote_file local_archive_path do
    source package_url
    action [:delete, :create]
  end

  execute 'unzip to directory' do
    command "unzip -o #{local_archive_path} -d #{application_directory}"
  end

  startup_script_path = "#{application_directory}/bin/#{project_name}"
  file startup_script_path do
    mode '0005'
    action :touch
  end

  directory application_directory do
    mode '0777'
    action :create
  end

  file pidfile_path do
    mode '0777'
    action :touch
  end

  template "/etc/init/play_#{project_name}.conf" do
    source 'upstart.conf.erb'
    cookbook 'play_framework'
    variables(
        :project_name => project_name,
        :start_command => start_command,
        :pidfile_path => pidfile_path,
        :application_directory => application_directory
    )
    action :create
  end
end

action :start do
  start
end

action :stop do
  stop
end

def start
  service project_name do
    action :start
  end
end

def startup_script
  "#{application_directory}/bin/#{project_name}"
end

def startup_args
  additional_args = @new_resource.arguments.map { |k, v| "-D#{k}=#{v}" }.join(' ')
  "-Dhttp.port=#{port} -Dpidfile.path=#{pidfile_path} #{additional_args}"
end

def start_command
  "#{startup_script} #{startup_args}"
end

def pidfile_path
  "/var/run/play_#{project_name}"
end

def remove_pidfile_command
  "((ps -A | grep `cat #{pidfile_path}`) || rm -f #{pidfile_path}) || if [ ! -s #{pidfile_path} ] ; then rm #{pidfile_path}; fi"
end

def stop
  service project_name do
    action :stop
  end
end

def application_directory
  @new_resource.install_path
end

def project_name
  @new_resource.name
end

def port
  @new_resource.port
end