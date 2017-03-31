require 'spec_helper'

describe 'solr-jetty::default' do

  platforms = {
    'centos' => ['7.0'],
    'ubuntu' => ['16.04']
  }

  platforms.each do |platform, versions|
    versions.each do |version|

      context "on #{platform.capitalize} #{version}" do
        let (:chef_run) do
          ChefSpec::SoloRunner.new(log_level: :error, platform: platform, version: version,
                                   file_cache_path: '/var/chef/cache') do |node|
            # set additional node attributes here
          end.converge(described_recipe)
        end

        it 'should include solr-jetty::prep by default' do
          expect(chef_run).to include_recipe('solr-jetty::prep')
        end

        it 'should include solr-jetty::package by default' do
          expect(chef_run).to include_recipe('solr-jetty::package')
        end
      end
    end
  end
end
