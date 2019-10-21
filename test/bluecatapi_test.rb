require 'mocha'
require 'webmock'
require 'webmock/test_unit'
require 'httparty'
require 'test_helper'
require 'dhcp_common/subnet'
require 'smart_proxy_dhcp_bluecat/bluecat_api'

class BluecatApiTest < Test::Unit::TestCase
  def setup
    @connection = BlueCat.new('https', true, 'bam.example.com', 123456, 'default', 'default', 100881, 123456, 'admin', 'admin')
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

  def test_next_ip
    fixture_response_login = fixture('test_rest_login.txt')
    stub_request(:get, 'https://bam.example.com/Services/REST/v1/login?password=admin&username=admin').
      with(
        headers: {
          'Content-Type' => 'text/plain'
        }
      ).
      to_return(status: 200, body: fixture_response_login)

    fixture_response = fixture('test_next_ip-getIPRangedByIP.json')
    stub_request(:get, "https://bam.example.com/Services/REST/v1/getIPRangedByIP?address=10.100.36.0&containerId=100881&type=IP4Network").
      with(
        headers: {
          'Authorization' => 'BAMAuthToken: Cr1gQMTU3MTM3NzXXXXXXXXXXXXJlbWFuLXByb3h',
          'Content-Type' => 'application/json'
        }
      ).
      to_return(status: 200, body: fixture_response)

    fixture_response2 = fixture('test_next_ip-getNextIP4Address.json').strip
    stub_request(:get, "https://bam.example.com/Services/REST/v1/getNextIP4Address?parentId=242527&properties=offset=10.100.36.10%7CexcludeDHCPRange=false").
      with(
        headers: {
          'Authorization' => 'BAMAuthToken: Cr1gQMTU3MTM3NzXXXXXXXXXXXXJlbWFuLXByb3h',
          'Content-Type' => 'application/json'
        }
      ).
      to_return(status: 200, body: fixture_response2)

    expected = "10.100.36.159"

    assert_equal expected, @connection.next_ip('10.100.36.0', '10.100.36.10', '10.100.36.30')
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
    stub_request(:get, "https://bam.example.com/Services/REST/v1/getIPRangedByIP?address=10.100.36.0&containerId=100881&type=IP4Network").
      with(
        headers: {
          'Authorization' => 'BAMAuthToken: Cr1gQMTU3MTM3NzXXXXXXXXXXXXJlbWFuLXByb3h',
          'Content-Type' => 'application/json'
        }
      ).
      to_return(status: 200, body: fixture_response)

    expected = ::Proxy::DHCP::Subnet.new('10.100.36.0', '255.255.255.192')

    assert_equal expected, @connection.find_mysubnet('10.100.36.0')
  end


  def test_hosts
    fixture_response_login = fixture('test_rest_login.txt')
    stub_request(:get, 'https://bam.example.com/Services/REST/v1/login?password=admin&username=admin').
      with(
        headers: {
          'Content-Type' => 'text/plain'
        }
      ).
      to_return(status: 200, body: fixture_response_login)

    fixture_response = fixture('test_hosts-getIPRangedByIP.json')
    stub_request(:get, "https://bam.example.com/Services/REST/v1/getIPRangedByIP?address=10.100.39.0&containerId=100881&type=IP4Network").
      with(
        headers: {
          'Authorization' => 'BAMAuthToken: Cr1gQMTU3MTM3NzXXXXXXXXXXXXJlbWFuLXByb3h',
          'Content-Type' => 'application/json'
        }
      ).
      to_return(status: 200, body: fixture_response)


      fixture_response2 = fixture('test_hosts-getNetworkLinkedProperties.json')
      stub_request(:get, "https://bam.example.com/Services/REST/v1/getNetworkLinkedProperties?networkId=242572").
        with(
          headers: {
              'Authorization'=>'BAMAuthToken: Cr1gQMTU3MTM3NzXXXXXXXXXXXXJlbWFuLXByb3h',
              'Content-Type'=>'application/json'
          }).
        to_return(status: 200, body: fixture_response2)



    expected = [::Proxy::DHCP::Reservation.new("host-dhcp.example.de", "10.100.39.10", "00:50:56:96:d7:88", ::Proxy::DHCP::Subnet.new('10.100.39.0', '255.255.255.192'), {:deleteable=>true, :hostname=>"host-dhcp.example.de"})]

    assert_equal expected, @connection.hosts('10.100.39.0')
  end


  def test_hosts_by_ip
    fixture_response_login = fixture('test_rest_login.txt')
    stub_request(:get, 'https://bam.example.com/Services/REST/v1/login?password=admin&username=admin').
      with(
        headers: {
          'Content-Type' => 'text/plain'
        }
      ).
      to_return(status: 200, body: fixture_response_login)

      fixture_response = fixture('test_hosts_by_ip-getIPRangedByIP.json')
      stub_request(:get, "https://bam.example.com/Services/REST/v1/getIPRangedByIP?address=10.100.36.16&containerId=100881&type=IP4Network").
        with(
          headers: {
            'Authorization' => 'BAMAuthToken: Cr1gQMTU3MTM3NzXXXXXXXXXXXXJlbWFuLXByb3h',
            'Content-Type' => 'application/json'
          }
        ).
        to_return(status: 200, body: fixture_response)


        fixture_response2 = fixture('test_hosts_by_ip-getIPRangedByIP.json')
        stub_request(:get, "https://bam.example.com/Services/REST/v1/getIP4Address?address=10.100.36.16&containerId=100881").
          with(
            headers: {
              'Authorization' => 'BAMAuthToken: Cr1gQMTU3MTM3NzXXXXXXXXXXXXJlbWFuLXByb3h',
              'Content-Type' => 'application/json'
            }
          ).
          to_return(status: 200, body: fixture_response2)


          fixture_response3 = fixture('test_hosts_by_ip-getLinkedEntities.json')
          stub_request(:get, "https://bam.example.com/Services/REST/v1/getLinkedEntities?count=2&entityId=242523&start=0&type=HostRecord").
            with(
              headers: {
                'Authorization' => 'BAMAuthToken: Cr1gQMTU3MTM3NzXXXXXXXXXXXXJlbWFuLXByb3h',
                'Content-Type' => 'application/json'
              }
            ).
            to_return(status: 200, body: fixture_response3)

            fixture_response4 = fixture('test_hosts_by_ip-getEntityById.json')
            stub_request(:get, "https://bam.example.com/Services/REST/v1/getEntityById?id=242523").
              with(
                headers: {
                  'Authorization' => 'BAMAuthToken: Cr1gQMTU3MTM3NzXXXXXXXXXXXXJlbWFuLXByb3h',
                  'Content-Type' => 'application/json'
                }
              ).
              to_return(status: 200, body: fixture_response4)



                expected = [::Proxy::DHCP::Reservation.new("examplehost.anotherdomain.com", "10.100.36.16", "00:50:56:96:ee:c0", ::Proxy::DHCP::Subnet.new('10.100.36.0', '255.255.255.192'), {:deleteable=>true, :hostname=>"examplehost.anotherdomain.com"})]


      assert_equal expected, @connection.hosts_by_ip('10.100.36.16')

    end


end
