#
# Cookbook Name:: solr-jetty
# Recipe:: package
#
# Copyright (C) 2015 NorthPage
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'libarchive::default'

src_filename = ::File.basename(node['solr-jetty']['url'])
src_filepath = "#{Chef::Config['file_cache_path']}/#{src_filename}"
dirname = "solr-#{node['solr-jetty']['version']}"

remote_file src_filepath do
  source node['solr-jetty']['url']
  owner node['solr-jetty']['user']
  action :create_if_missing
  notifies :extract, "libarchive_file[extract_solr]", :immediately
  notifies :run, "bash[backup_existing]", :immediately
  notifies :run, "bash[copy_solr]", :immediately
end

libarchive_file "extract_solr" do
  path src_filepath
  extract_to "#{node['solr-jetty']['install_dir']}"
  owner node['solr-jetty']['user']
  extract_options :no_overwrite
  action :nothing
end

bash 'backup_existing' do
  cwd node['solr-jetty']['install_dir']
  code <<-EOH
    mv solr solr.upgade-to-#{node['solr-jetty']['version']}
  EOH
  only_if { ::File.exist?("#{node['solr-jetty']['install_dir']}/solr") }
  action :nothing
end

bash 'copy_solr' do
  cwd node['solr-jetty']['install_dir']
  code <<-EOH
    cp -pr #{dirname}/example solr
    # chown -Rh #{node['solr-jetty']['user']} solr
  EOH
  not_if { ::File.exist?("#{node['solr-jetty']['install_dir']}/solr") }
  action :nothing
end

if node['solr-jetty']['init_system'] == 'systemd'
  solr_jetty_init = '/usr/lib/systemd/system/solr.service'
  init_template_source = 'solr-jetty.systemd.erb'
else
  solr_jetty_init = '/etc/init.d/solr'
  init_template_source = 'solr-jetty.sysv.erb'
end

case node['platform_family']
  when 'rhel'
    solr_jetty_config = '/etc/sysconfig/solr'
  when 'debian'
    solr_jetty_config = '/etc/default/solr'
  else
    solr_jetty_config = '/etc/sysconfig/solr'
end

template solr_jetty_config do
  source 'solr-jetty-config.erb'
  variables({
    :java_home  => node['java']['java_home'],
    :solr_dir   => "#{node['solr-jetty']['install_dir']}/solr",
    :solr_data  => "#{node['solr-jetty']['data_dir']}",
    :solr_user  => node['solr-jetty']['user']
  })
end

template solr_jetty_init do
  source init_template_source
  owner 'root'
  mode '0755'
  variables({
    :config => solr_jetty_config,
    :java => "#{node['java']['java_home']}/bin/java",
    :solr_user => node['solr-jetty']['user'],
    :solr_dir => "#{node['solr-jetty']['install_dir']}/solr",
    :solr_data => "#{node['solr-jetty']['data_dir']}",
  })
  action :create
end

service 'solr' do
  action :enable
end
