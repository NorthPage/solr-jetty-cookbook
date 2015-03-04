require 'spec_helper'


describe 'solr-jetty::package' do

  platforms = {
      'centos' => ['6.6'],
      'ubuntu' => ['14.04']
  }

  platforms.each do |platform, versions|
    versions.each do |version|

      context "on #{platform.capitalize} #{version}" do
        let (:chef_run) do
          ChefSpec::SoloRunner.new(log_level: :error, platform: platform, version: version) do |node|
            # set additional node attributes here
          end.converge(described_recipe)
        end

        it 'should include libarchive::default by default' do
          expect(chef_run).to include_recipe('libarchive::default')
        end

        it 'should download the solr archive' do
          expect(chef_run).to create_remote_file_if_missing("#{Chef::Config['file_cache_path']}/solr-4.10.2.tgz")
        end

        it 'should create the solr init script' do
          expect(chef_run).to create_cookbook_file('/etc/init.d/solr')
        end

        it 'should render the solr config' do
          if platform == 'centos'
            config_file = '/etc/sysconfig/solr'
          elsif platform == 'ubuntu'
            config_file = '/etc/default/solr'
          end
          expect(chef_run).to render_file(config_file)
        end
      end
    end
  end
end
