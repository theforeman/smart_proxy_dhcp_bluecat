require 'mocha'
require 'webmock'
require 'webmock/test_unit'
require 'httparty'
require 'test_helper'
require 'dhcp_common/subnet'
require 'smart_proxy_dhcp_bluecat/bluecat_api'

class BluecatApiTest < Test::Unit::TestCase
  def setup
    @connection = BlueCat::Client.new(scheme: 'https', verify: true, host: 'bam.example.com', parent_block: 123456, view_name: 'default', config_name: 'default',  config_id: 123456, server_id: 123456, username: 'admin', password: 'admin')
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

  def test_get_next_ip
    fixture_response = fixture('getNextIP4Address.json')

    stub_request(:get, 'https://bam.example.com/Services/REST/v1/getNextIP4Address?parentId=242527&properties=offset=10.100.36.139%7CexcludeDHCPRange=false').
    with(
      headers: {
        'Authorization' => 'BAMAuthToken:',
        'Content-Type' => 'application/json'
      }
    ).
    to_return(status: 200, body: fixture_response)

    expected = "10.100.36.159"

    assert_equal expected, @connection.get_next_ip
  end

end
