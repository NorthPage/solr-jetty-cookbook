require 'spec_helper'

describe 'solr-jetty::prep' do

  platforms = {
    'centos' => ['6.6', '7.0'],
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

        it 'should include java::default by default' do
          expect(chef_run).to include_recipe('java::default')
        end

        it 'should create the solr user' do
          expect(chef_run).to create_user('solr')
        end

        it 'should create the solr data directory' do
          expect(chef_run).to create_directory('/opt/solr-data').with_owner('solr')
        end
      end
    end
  end
end
