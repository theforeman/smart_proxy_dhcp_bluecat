require 'test_helper'
require 'dhcp_common/dhcp_common'
require 'smart_proxy_dhcp_bluecat/plugin_configuration'
require 'smart_proxy_dhcp_bluecat/scheme_validator'
require 'smart_proxy_dhcp_bluecat/verify_validator'
require 'smart_proxy_dhcp_bluecat/module_loader'
require 'smart_proxy_dhcp_bluecat/dhcp_bluecat_plugin'
require 'smart_proxy_dhcp_bluecat/bluecat_api'
require 'smart_proxy_dhcp_bluecat/dhcp_bluecat_main'

class bluecatDhcpProductionWiringTest < Test::Unit::TestCase
  def setup
    @settings = {:username => 'user', :password => 'password',
                 :server => '10.10.10.10', :scheme => 'https',
                 :verify => true, :subnets => ['1.1.1.0/255.255.255.0']}
    @container = ::Proxy::DependencyInjection::Container.new
    Proxy::DHCP::Bluecat::PluginConfiguration.new.load_dependency_injection_wirings(@container, @settings)
  end

  def test_connection_initialization
    connection = @container.get_dependency(:connection)
    assert_equal '10.10.10.10', connection.host
    assert_equal 'user', connection.username
    assert_equal 'password', connection.password
    assert_equal 'https', connection.scheme
    assert_equal true, connection.verify
  end

  def test_provider
    provider = @container.get_dependency(:dhcp_provider)
    assert provider.instance_of?(::Proxy::DHCP::Bluecat::Provider)
  end

end
