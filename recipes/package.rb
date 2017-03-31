#
# Cookbook Name:: solr-jetty
# Recipe:: package
#
# Copyright (C) 2015-2017 NorthPage
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
  notifies :extract, 'libarchive_file[extract_solr]', :immediately
  notifies :run, 'bash[backup_existing]', :immediately
  notifies :create, 'directory[solr_collections]', :immediately
end

libarchive_file 'extract_solr' do
  path src_filepath
  extract_to node['solr-jetty']['install_dir']
  owner node['solr-jetty']['user']
  extract_options :no_overwrite
  action :nothing
end

bash 'backup_existing' do
  cwd node['solr-jetty']['install_dir']
  code <<-EOH
    mv solr solr.upgade-to-#{node['solr-jetty']['version']}
  EOH
  only_if { ::File.directory?("#{node['solr-jetty']['install_dir']}/solr") }
  action :nothing
end

directory 'solr_collections' do
  path "#{node['solr-jetty']['install_dir']}/solr"
  recursive true
  owner node['solr-jetty']['user']
  action :nothing
  notifies :run, 'bash[copy_solr]', :immediately
end

bash 'copy_solr' do
  cwd node['solr-jetty']['install_dir']
  code <<-EOH
    cp -pr #{dirname}/server/solr #{node['solr-jetty']['install_dir']}/solr/
    chown -Rh #{node['solr-jetty']['user']} solr
  EOH
  action :nothing
end

template '/etc/systemd/system/solr.service' do
  source 'solr-jetty.systemd.erb'
  owner 'root'
  mode '0644'
  variables(
    datadir: node['solr-jetty']['data_dir'],
    homedir: node['solr-jetty']['home_dir'],
    installdir: "#{node['solr-jetty']['install_dir']}/#{dirname}",
    memory: node['solr-jetty']['memory'],
    port: node['solr-jetty']['port'],
    serverdir: "#{node['solr-jetty']['install_dir']}/#{dirname}/server",
    user: node['solr-jetty']['user']
  )
  action :create
  notifies :run, 'bash[reload systemd daemon]', :immediately
end

bash 'reload systemd daemon' do
  code 'systemctl daemon-reload'
  action :nothing
end

service 'solr' do
  action [:enable, :start]
end
