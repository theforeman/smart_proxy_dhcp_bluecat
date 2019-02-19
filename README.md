# SmartProxyDhcpBlueCat

This plugin adds a new DHCP provider for managing records with BlueCat Address Manager.
The Provider manages dhcp reservations and A&PTR records.

## Installation

See [How_to_Install_a_Smart-Proxy_Plugin](http://projects.theforeman.org/projects/foreman/wiki/How_to_Install_a_Smart-Proxy_Plugin)
for how to install Smart Proxy plugins

This plugin is compatible with Smart Proxy 1.16 or higher.

When installing using "gem", make sure to install the bundle file:

    echo "gem 'smart_proxy_dhcp_bluecat', :git => 'https://gitlab.sixt.de/datacenter-mgmt/smart_proxy_dhcp_bluecat'" > /usr/share/foreman-proxy/bundler.d/dhcp_bluecat.rb

## Configuration

To enable this DHCP provider, edit `/etc/foreman-proxy/settings.d/dhcp.yml` and set:

    :use_provider: dhcp_bluecat
    :subnets: subnets you want to use (optional)

Configuration options for this plugin are in `/etc/foreman-proxy/settings.d/dhcp_bluecat.yml` and include:

    :scheme: connection mode to the Bluecat address manager
    :verify: validate ssl connection
    :host: FQDN or IP of the Bluecat address manager
    :parent_block: parent_block Id that holds your subnets
    :view_name: Bluecat DNS view name
    :config_id: Bluecat configuration id
    :config_name: Bluecat configuration name
    :server_id: id of your dhcp server
    :username: API Username
    :password: API Password

## Limitations
    IPv6 Records are currently not implemented
    Adresses with expired DHCP Leases are not handed out as free IPs by Bluecat

## Contributing

Fork and send a Pull Request. Thanks!

## Copyright

Copyright (c) 2018 Sixt GmbH & Co. Autovermietung KG
