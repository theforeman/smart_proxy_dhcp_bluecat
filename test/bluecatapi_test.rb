require 'mocha'
require 'webmock'
require 'webmock/test_unit'
require 'httparty'
require 'test_helper'
require 'dhcp_common/subnet'
require 'smart_proxy_dhcp_bluecat/bluecat_api'

class BluecatApiTest < Test::Unit::TestCase
  def setup
    @connection = BlueCat.new(scheme: 'https', verify: true, host: 'bam.example.com', parent_block: 123456, view_name: 'default', config_name: 'default', config_id: 123456, server_id: 123456, username: 'admin', password: 'admin')
  end

  def test_rest_login
    fixture_response_login = fixture('test_rest_login.txt')

    stub_request(:get, 'https://bam.example.com/Services/REST/v1/login?password=admin&username=admin').
      with(
        headers: {
          'Content-Type' => 'text/plain'
        }
      ).
      to_return(status: 200, body: fixture_response_login)

    expected = "Cr1gQMTU3MTM3NzXXXXXXXXXXXXJlbWFuLXByb3h"
    assert_equal expected, @connection.rest_login
  end

  def test_subnets
    fixture_response_login = fixture('test_rest_login.txt')

    stub_request(:get, 'https://bam.example.com/Services/REST/v1/login?password=admin&username=admin').
      with(
        headers: {
          'Content-Type' => 'text/plain'
        }
      ).
      to_return(status: 200, body: fixture_response_login)

    fixture_response = fixture('test_subnets-getEntities.json')

    stub_request(:get, 'https://bam.example.com/Services/REST/v1/getEntities?count=10000&parentId=123456&start=0&type=IP4Network').
      with(
        headers: {
          'Authorization' => 'BAMAuthToken: Cr1gQMTU3MTM3NzXXXXXXXXXXXXJlbWFuLXByb3h',
          'Content-Type' => 'application/json'
        }
      ).
      to_return(status: 200, body: fixture_response)

    expected = [
      ::Proxy::DHCP::Subnet.new('10.100.0.0', '255.255.255.0', routers: ['10.100.0.1']),
      ::Proxy::DHCP::Subnet.new('10.100.1.0', '255.255.255.0', routers: ['10.100.1.1'])
    ]

    assert_equal expected, @connection.subnets
  end

  def test_get_next_ip
    fixture_response_login = fixture('test_rest_login.txt')

    stub_request(:get, 'https://bam.example.com/Services/REST/v1/login?password=admin&username=admin').
      with(
        headers: {
          'Content-Type' => 'text/plain'
        }
      ).
      to_return(status: 200, body: fixture_response_login)

    fixture_response = fixture('test_get_next_ip-getIPRangedByIP.json')
    fixture_response2 = fixture('test_get_next_ip-getNextIP4Address.json').strip

    stub_request(:get, "https://bam.example.com/Services/REST/v1/getIPRangedByIP?address=10.100.36.0&containerId=123456&type=IP4Network").
      with(
        headers: {
          'Authorization' => 'BAMAuthToken: Cr1gQMTU3MTM3NzXXXXXXXXXXXXJlbWFuLXByb3h',
          'Content-Type' => 'application/json'
        }
      ).
      to_return(status: 200, body: fixture_response)

    stub_request(:get, "https://bam.example.com/Services/REST/v1/getNextIP4Address?parentId=242527&properties=offset=10.100.36.10%7CexcludeDHCPRange=false").
      with(
        headers: {
          'Authorization' => 'BAMAuthToken: Cr1gQMTU3MTM3NzXXXXXXXXXXXXJlbWFuLXByb3h',
          'Content-Type' => 'application/json'
        }
      ).
      to_return(status: 200, body: fixture_response2)

    expected = "10.100.36.159"

    assert_equal expected, @connection.get_next_ip(netadress: '10.100.36.0', start_ip: '10.100.36.10', end_ip: '10.100.36.30')
  end

  def test_find_mysubnet
    fixture_response_login = fixture('test_rest_login.txt')

    stub_request(:get, 'https://bam.example.com/Services/REST/v1/login?password=admin&username=admin').
      with(
        headers: {
          'Content-Type' => 'text/plain'
        }
      ).
      to_return(status: 200, body: fixture_response_login)

    fixture_response = fixture('test_find_mysubnet-getIPRangedByIP.json')

    stub_request(:get, "https://bam.example.com/Services/REST/v1/getIPRangedByIP?address=10.100.36.0&containerId=123456&type=IP4Network").
      with(
        headers: {
          'Authorization' => 'BAMAuthToken: Cr1gQMTU3MTM3NzXXXXXXXXXXXXJlbWFuLXByb3h',
          'Content-Type' => 'application/json'
        }
      ).
      to_return(status: 200, body: fixture_response)

    expected = ::Proxy::DHCP::Subnet.new('10.100.36.0', '255.255.255.192')

    assert_equal expected, @connection.find_mysubnet(subnet_address: '10.100.36.0')
  end
end
