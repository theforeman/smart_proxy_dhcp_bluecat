require 'mocha'
require 'webmock'
require 'webmock/test_unit'
require 'httparty'
require 'test_helper'
require 'dhcp_common/subnet'
require 'smart_proxy_dhcp_bluecat/bluecat_api'

class BluecatApiTest < Test::Unit::TestCase
  def setup
    @connection = BlueCat.new('https', true, 'bam.example.com', 123456, 'default', 123456, 'default', 123456, 'admin', 'admin')
  end

  def test_get_subnets
    fixture_response = fixture('get_entities.json')

    stub_request(:get, 'https://bam.example.com/Services/REST/v1/getEntities?count=10000&parentId=123456&start=0&type=IP4Network').
    with(
      headers: {
        'Authorization' => 'BAMAuthToken:',
  	    'Content-Type' => 'application/json'
      }
    ).
    to_return(status: 200, body: fixture_response)

    expected = [
      ::Proxy::DHCP::Subnet.new('10.100.0.0', '255.255.255.0', routers: ['10.100.0.1']),
      ::Proxy::DHCP::Subnet.new('10.100.1.0', '255.255.255.0', routers: ['10.100.1.1'])
    ]

    assert_equal expected, @connection.get_subnets
  end
end
