require File.expand_path('../lib/smart_proxy_dhcp_bluecat/dhcp_bluecat_version', __FILE__)
require 'date'

Gem::Specification.new do |s|
  s.name        = 'smart_proxy_dhcp_bluecat'
  s.version     = Proxy::DHCP::BlueCat::VERSION
  s.date        = Date.today.to_s
  s.license     = 'GPL-3.0'
  s.authors     = ['Matthias Hähnel']
  s.email       = ['matthias.haehnel@sixt.com']
  s.homepage    = 'https://www.sixt.com'

  s.summary     = "BlueCat DHCP provider plugin for Foreman's smart proxy"
  s.description = "BlueCat DHCP provider plugin for Foreman's smart proxy"

  s.files       = Dir['{config,lib,bundler.d}/**/*'] + ['README.md', 'LICENSE']
  s.add_dependency 'savon', '~> 2.0'
  s.add_dependency 'netaddr', '~> 1.5', '>= 1.5.1'

end
