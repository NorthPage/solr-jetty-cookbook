require 'spec_helper'

describe command('java -version') do
  its(:stderr) { should match(/1.8.0/) }
end

describe user('solr') do
  it { should exist }
end

describe package('lsof') do
  it { should be_installed }
end

describe file('/opt/solr') do
  it { should be_directory }
end

describe file('/opt/solr-data') do
  it { should be_directory }
end

