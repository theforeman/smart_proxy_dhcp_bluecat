require File.expand_path("lib/smart_proxy_dhcp_bluecat/dhcp_bluecat_version", __dir__)
require "date"

Gem::Specification.new do |s|
  s.name = "smart_proxy_dhcp_bluecat"
  s.version = Proxy::DHCP::BlueCat::VERSION
  s.license = "GPL-3.0"
  s.authors = ["Matthias Hähnel", "The Foreman Team"]
  s.email = ["matthias.haehnel@sixt.com", "theforeman.rubygems@gmail.com"]
  s.homepage = "https://github.com/theforeman/smart_proxy_dhcp_bluecat"

  s.summary = "BlueCat DHCP provider plugin for Foreman's smart proxy"
  s.description = "BlueCat DHCP provider plugin for Foreman's smart proxy"
  s.required_ruby_version = ">= 2.5"

  s.files = Dir["{config,lib,bundler.d}/**/*"] + ["README.md", "LICENSE"]
  s.add_dependency "httparty"
  s.add_dependency "ipaddress"
end
