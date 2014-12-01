default['solr-jetty']['version']  = '4.10.2'
default['solr-jetty']['url']      = "https://archive.apache.org/dist/lucene/solr/#{node['solr-jetty']['version']}/solr-#{node['solr-jetty']['version']}.tgz"
default['solr-jetty']['install_dir'] = '/opt'
default['solr-jetty']['data_dir'] = "#{node['solr-jetty']['install_dir']}/solr-data"
default['solr-jetty']['port']     = '8983'
default['solr-jetty']['user']     = 'solr'
default['solr-jetty']['install_java'] = true
default['solr-jetty']['manage_user'] = true
