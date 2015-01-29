include_recipe 'apt'

apt_repository "webupd8team" do
  uri "http://ppa.launchpad.net/webupd8team/java/ubuntu"
  components ['main']
  distribution node['lsb']['codename']
  keyserver "keyserver.ubuntu.com"
  key "EEA14886"
  deb_src true
end

# could be improved to run only on update
execute "accept-license-1" do
  command "echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | \\sudo debconf-set-selections"
end

#ubuntu 12
execute "accept-license-2" do
  command "echo debconf shared/accepted-oracle-license-v1-1 select true | \\sudo debconf-set-selections"
end

execute "accept-license-3" do
  command "echo debconf shared/accepted-oracle-license-v1-1 seen true | \\sudo debconf-set-selections"
end

package "oracle-java8-installer" do
  action :install
end

package "oracle-java8-set-default" do
  action :install
end

package "unzip" do
  action :install
end