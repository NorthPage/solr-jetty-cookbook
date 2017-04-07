require 'spec_helper'

describe file('/opt/solr-6.5.0') do
  it { should be_directory }
end

describe file('/opt/solr/solr') do
  it { should be_directory }
end

describe file('/opt/solr/solr/solr.xml') do
  it { should be_file }
end

describe service('solr') do
  it { should be_enabled }
  it { should be_running }
end

describe port(8983) do
  it { should be_listening }
end
