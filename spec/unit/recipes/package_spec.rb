require 'spec_helper'

describe 'solr-jetty::package' do

  platforms = {
    'centos' => ['7.0'],
    'ubuntu' => ['16.04']
  }

  platforms.each do |platform, versions|
    versions.each do |version|

      context "on #{platform.capitalize} #{version}" do
        let(:chef_run) do
          ChefSpec::SoloRunner.new(log_level: :error, platform: platform,
                                   version: version, file_cache_path: '/var/chef/cache') do |node|
            # set additional node attributes here
          end.converge(described_recipe)
        end

        it 'should include libarchive::default by default' do
          expect(chef_run).to include_recipe('libarchive::default')
        end

        it 'should download the solr archive' do
          tgz = '/var/chef/cache/solr-6.5.0.tgz'
          expect(chef_run).to create_remote_file_if_missing(tgz)
        end

        it 'registers but does not run a bash script to backup the existing solr' do
          backup_existing = chef_run.bash('backup_existing')
          expect(backup_existing).to do_nothing
        end

        it 'registers but does not run a bash script to copy solr' do
          copy_solr = chef_run.bash('copy_solr')
          expect(copy_solr).to do_nothing
        end

        it 'registers but does not run a bash script to reload systemd' do
          reload_systemd = chef_run.bash('reload systemd daemon')
          expect(reload_systemd).to do_nothing
        end

        it 'should create the solr init script' do
          init = chef_run.template('/etc/systemd/system/solr.service')
          expect(chef_run).to render_file('/etc/systemd/system/solr.service')
          expect(init).to notify('bash[reload systemd daemon]').immediately
        end

        it 'should create and enable the solr service' do
          expect(chef_run).to enable_service('solr')
        end

        it 'should notify installation scripts when an archive is downloaded' do
          archive = chef_run.remote_file('/var/chef/cache/solr-6.5.0.tgz')
          expect(archive).to notify('libarchive_file[extract_solr]').immediately
          expect(archive).to notify('bash[backup_existing]').immediately
          expect(archive).to notify('directory[solr_collections]').immediately
        end
      end
    end
  end
end
