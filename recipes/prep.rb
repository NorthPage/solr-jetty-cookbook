#
# Cookbook Name:: solr-jetty
# Recipe:: prep
#
# Copyright (C) 2014 NorthPage
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

if node['solr-jetty']['install_java']
  node.set['java']['jdk_version'] = '7'
  node.set['java']['install_flavor'] = 'oracle'
  node.set['java']['oracle']['accept_oracle_download_terms'] = true
  include_recipe 'java::default'
end

if node['solr-jetty']['manage_user']
  user node['solr-jetty']['user'] do
    system true
    action [:create,:manage]
  end
end

directory node['solr-jetty']['data_dir'] do
  recursive true
  owner node['solr-jetty']['user']
  action :create
end
