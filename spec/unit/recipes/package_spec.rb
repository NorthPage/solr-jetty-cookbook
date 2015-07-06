require 'spec_helper'

describe 'solr-jetty::package' do

  platforms = {
    'centos' => ['6.6', '7.0'],
    'ubuntu' => ['14.04']
  }

  platforms.each do |platform, versions|
    versions.each do |version|

      context "on #{platform.capitalize} #{version}" do
        let (:chef_run) do
          ChefSpec::SoloRunner.new(log_level: :error, platform: platform,
                                   version: version, file_cache_path: '/var/chef/cache') do |node|
            # set additional node attributes here
          end.converge(described_recipe)
        end

        let(:archive) { chef_run.remote_file('/var/chef/cache/solr-4.10.2.tgz') }

        it 'should include libarchive::default by default' do
          expect(chef_run).to include_recipe('libarchive::default')
        end

        it 'should download the solr archive' do
          expect(chef_run).to create_remote_file_if_missing('/var/chef/cache/solr-4.10.2.tgz')
        end

        it 'should create the solr init script' do
          if platform == 'centos' && version.to_i >= 7
            init_script = '/usr/lib/systemd/system/solr.service'
          else
            init_script = '/etc/init.d/solr'
          end
          expect(chef_run).to render_file(init_script)
        end

        it 'registers but does not run a bash script to backup the existing solr' do
          backup_existing = chef_run.bash('backup_existing')
          expect(backup_existing).to do_nothing
        end

        it 'registers but does not run a bash script to copy solr in place' do
          copy_solr = chef_run.bash('copy_solr')
          expect(copy_solr).to do_nothing
        end

        it 'should render the solr config' do
          if platform == 'centos'
            config_file = '/etc/sysconfig/solr'
          elsif platform == 'ubuntu'
            config_file = '/etc/default/solr'
          end
          expect(chef_run).to render_file(config_file)
        end

        it 'should create and enable the solr service' do
          expect(chef_run).to enable_service('solr')
        end

        it 'should notify installation scripts when an archive is downloaded' do
          expect(archive).to notify('bash[backup_existing]').immediately
          expect(archive).to notify('bash[copy_solr]').immediately
        end
      end
    end
  end
end
