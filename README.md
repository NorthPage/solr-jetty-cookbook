# solr-jetty-cookbook

Installs and configures Solr

This cookbook uses concepts from https://github.com/dwradcliffe/chef-solr, but
uses the libarchive cookbook and allows running as a non-root user.

## Supported Platforms

* Centos 7.0
* Ubuntu 16.04

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['solr-jetty']['version']</tt></td>
    <td>String</td>
    <td>Solr version to install</td>
    <td><tt>4.10.2</tt></td>
  </tr>
  <tr>
    <td><tt>['solr-jetty']['url']</tt></td>
    <td>String</td>
    <td>The URL for pulling solr</td>
    <td><tt>https://archive.apache.org/dist/lucene/solr/#{node['solr-jetty']['version']}/solr-#{node['solr-jetty']['version']}.tgz</tt></td>
  </tr>
  <tr>
    <td><tt>['solr-jetty']['install_dir']</tt></td>
    <td>String</td>
    <td>Where to install solr</td>
    <td><tt>/opt</tt></td>
  </tr>
  <tr>
    <td><tt>['solr-jetty']['port']</tt></td>
    <td>String</td>
    <td>The listen port for solr</td>
    <td><tt>8983</tt></td>
  </tr>
  <tr>
    <td><tt>['solr-jetty']['user']</tt></td>
    <td>String</td>
    <td>The user to run solr</td>
    <td><tt>solr</tt></td>
  </tr>
  <tr>
    <td><tt>['solr-jetty']['manage_user']</tt></td>
    <td>Boolean</td>
    <td>Create/manage the solr user.</td>
    <td><tt>true</tt></td>
  </tr>
  <tr>
    <td><tt>['solr-jetty']['install_java']</tt></td>
    <td>Boolean</td>
    <td>Enable/disable java installation (via the `java` cookbook)</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

### solr-jetty::default

Include `solr-jetty` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[solr-jetty::default]"
  ]
}
```

* If `node['solr-jetty']['install_java']` is `true`, it installs and configures oracle java 7
* If `node['solr-jetty']['manage_user']` is `true`, it will create and manage `node['solr-jetty']['user']`
* Downloads the solr archive (for the given version) and extracts it into `node['solr-jetty']['install_dir']`
* If `node['solr-jetty']['install_dir']`/solr exists, it will be moved
* Copies `node['solr-jetty']['install_dir']`/solr-`node['solr-jetty']['version']`/example to `node['solr-jetty']['install_dir']`/solr
* If the version is changed, or the archive is deleted from disk, solr will be reinstalled
* Installs init scripts and platform specific configuration
* If you want to open the listen port, include `recipe[solr-jetty::iptables]` recipe

## License and Authors

Author:: E Camden Fisher (<camden@northpage.com>)  
Copyright (C) 2015 NorthPage

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
