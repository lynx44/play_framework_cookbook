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
    mode '0666'
    action :create
  end

  file pid_file_path do
    mode '0666'
    action :touch
  end

  template "/etc/init/play_#{project_name}.conf" do
    source 'upstart.conf.erb'
    cookbook 'play_framework'
    variables(
        :project_name => project_name,
        :start_command => start_command
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
  execute 'start website' do
    command "nohup #{start_command} &"
  end
end

def startup_script
  "#{application_directory}/bin/#{project_name}"
end

def startup_args
  "-Dhttp.port=#{port}"
end

def start_command
  "start-stop-daemon --start --pidfile #{pid_file_path} --exec #{startup_script} -- #{startup_args}"
end

def stop_command
  "start-stop-daemon --stop --pidfile #{pid_file_path} --exec #{startup_script} -- #{startup_args}"
end

def pid_file_path
  "#{application_directory}/RUNNING_PID"
end

def stop
  # running_pid_path = "#{application_directory}/RUNNING_PID"
  # execute 'kill existing instance' do
  #   command "sudo kill `cat #{running_pid_path}`"
  #   only_if {::File.exist? running_pid_path }
  #   returns [0,1]
  # end

  execute 'stop existing instance' do
    command stop_command
    returns [0,1]
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