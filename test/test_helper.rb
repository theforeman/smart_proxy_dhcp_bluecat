$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require "test/unit"
require "mocha/test_unit"
require 'webmock'
require 'webmock/test_unit'
require 'httparty'
require 'smart_proxy_for_testing'
require 'dhcp_common/subnet'
require 'smart_proxy_dhcp_bluecat/bluecat_api'


# create log directory in our (not smart-proxy) directory
FileUtils.mkdir_p File.dirname(Proxy::SETTINGS.log_file)

def fixture(name)
  File.read(File.expand_path("../fixtures/#{name}", __FILE__))
end
