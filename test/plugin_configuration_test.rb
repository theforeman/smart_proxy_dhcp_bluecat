require 'test_helper'
require 'dhcp_common/dhcp_common'
require 'smart_proxy_dhcp_bluecat/plugin_configuration'
require 'smart_proxy_dhcp_bluecat/settings_validator'
require 'smart_proxy_dhcp_bluecat/module_loader'
require 'smart_proxy_dhcp_bluecat/dhcp_bluecat_plugin'
require 'smart_proxy_dhcp_bluecat/bluecat_api'
require 'smart_proxy_dhcp_bluecat/dhcp_bluecat_main'

# class BlueCatDhcpProductionWiringTest < Test::Unit::TestCase
#   def setup
#     @settings = { :scheme => 'https',
#                   :verify => true,
#                   :host => '10.10.10.10',
#                   :parent_block => 242_435,
#                   :view_name => 'default',
#                   :config_name => 'Sixt',
#                   :config_id => 100_881,
#                   :server_id => 100_901,
#                   :username => 'apiuser',
#                   :password => 'password' }
#
#     @container = ::Proxy::DependencyInjection::Container.new
#     Proxy::DHCP::BlueCat::PluginConfiguration.new.load_dependency_injection_wirings(@container, @settings)
#   end
#
#   def test_connection_initialization
#     connection = @container.get_dependency(:connection)
#     assert_equal 'https', connection.scheme
#     assert_equal true, connection.verify
#     assert_equal '10.10.10.10', connection.host
#     assert_equal 242_435, connection.parent_block
#     assert_equal 'default', connection.view_name
#     assert_equal 'Sixt', connection.config_name
#     assert_equal 100_881, connection.config_id
#     assert_equal 100_901, connection.server_id
#     assert_equal 'user', connection.username
#     assert_equal 'password', connection.password
#   end
#
#   def test_provider
#     provider = @container.get_dependency(:dhcp_provider)
#     assert provider.instance_of?(::Proxy::DHCP::BlueCat::Provider)
#   end
# end
