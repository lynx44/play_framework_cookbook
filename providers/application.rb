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

  file "#{application_directory}/bin/#{project_name}" do
    mode '0005'
    :touch
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
    command "nohup #{application_directory}/bin/#{project_name} -Dhttp.port=9000 &"
  end
end

def stop
  running_pid_path = "#{application_directory}/RUNNING_PID"
  execute 'kill existing instance' do
    command "sudo kill `cat #{running_pid_path}`"
    only_if {::File.exist? running_pid_path }
    returns [0,1]
  end
end

def application_directory
  @new_resource.install_path
end

def project_name
  @new_resource.name
end