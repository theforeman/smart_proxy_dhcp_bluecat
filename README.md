# SmartProxyDhcpBlueCat

This plugin adds a new DHCP provider for managing records with BlueCat Address Manager

## Installation

See [How_to_Install_a_Smart-Proxy_Plugin](http://projects.theforeman.org/projects/foreman/wiki/How_to_Install_a_Smart-Proxy_Plugin)
for how to install Smart Proxy plugins

This plugin is compatible with Smart Proxy 1.16 or higher.

When installing using "gem", make sure to install the bundle file:

    echo "gem 'smart_proxy_dhcp_bluecat', :git => 'https://github.com/m4c3/smart_proxy_dhcp_bluecat/'" > /usr/share/foreman-proxy/bundler.d/dhcp_bluecat.rb

## Configuration

To enable this DHCP provider, edit `/etc/foreman-proxy/settings.d/dhcp.yml` and set:

    :use_provider: dhcp_bluecat
    :subnets: subnets you want to use (optional)

Configuration options for this plugin are in `/etc/foreman-proxy/settings.d/dhcp_bluecat.yml` and include:

    :scheme: connection mode to the Bluecat address manager
    :verify: validate ssl connection
    :host: FQDN or IP of the Bluecat address manager
    :parentBlock: parentBlock Id that holds your subnets
    :viewName: Bluecat DNS view name
    :configId: Bluecat configuration id
    :configName: Bluecat configuration name
    :serverId: id of your dhcp server
    :username: API Username
    :password: API Password


## Contributing

Fork and send a Pull Request. Thanks!

## Copyright

Copyright (c) 2018 Sixt GmbH & Co. Autovermietung KG
