require 'mocha'
require 'webmock'
require 'webmock/test_unit'
require 'httparty'
require 'test_helper'
require 'smart_proxy_dhcp_bluecat/bluecat_api'

class BluecatApiTest < Test::Unit::TestCase
  def setup
    @connection = Proxy::DHCP::Bluecat.new('10.10.10.10', 'https', false, 'admin', 'admin')
    @csv_string_subnet = "network,mask_bits,subnet_pk\n10.75.1.0,24,1\n"
    @array_subnet = [
      { 'mask_bits' => '24', 'network' => '10.75.1.0', 'subnet_pk' => '1' }
    ]
    @csv_string_host = "name,ip_address,hwaddress,network,mask_bits\njohn.doe.local,10.75.1.1,a2cdf8e990eb,10.75.1.0,24\n"
    @array_host = [{
      'hwaddress' => 'a2cdf8e990eb',
      'ip_address' => '10.75.1.1',
      'mask_bits' => '24',
      'name' => 'john.doe.local',
      'network' => '10.75.1.0'
    }]
    @csv_string_ips = "ip_address\n10.75.1.1\n10.75.1.2\n10.75.1.3"
    @ip_suggest_output = '{"ip":"10.75.1.20"}'
  end

  def test_csv_to_array
    assert_equal @array_subnet, @connection.csv_to_array(@csv_string_subnet)
  end

  def test_rest_get
    endpoint = 'test'
    qs = 'qs'
    req = stub_request(:get, format('%s://%s/api/1.0/%s/qs', @connection.scheme, @connection.host, endpoint)).to_return(status: 200, body: [{ 'test' => 'test' }].to_json)
    assert_equal [{ 'test' => 'test' }].to_json, @connection.rest_get(endpoint, qs)
    assert_requested req
  end

  def test_rest_post
    endpoint = 'test'
    req = stub_request(:post, format('%s://%s/api/1.0/%s/', @connection.scheme, @connection.host, endpoint)).to_return(status: 200, body: [{ 'test' => 'test' }].to_json)
    assert_equal [{ 'test' => 'test' }].to_json, @connection.rest_post(endpoint, {})
    assert_requested req
  end

  def test_rest_delete
    endpoint = 'test'
    id = 1
    req = stub_request(:delete, format('%s://%s/api/1.0/%s/%s/', @connection.scheme, @connection.host, endpoint, id)).to_return(status: 200, body: [{ 'test' => 'test' }].to_json)
    assert_equal [{ 'test' => 'test' }].to_json, @connection.rest_delete(endpoint, id)
    assert_requested req
  end

  def test_doql
    req = stub_request(:post, format('%s://%s/services/data/v1.0/query/', @connection.scheme, @connection.host)).to_return(status: 200, body: [{ 'test' => 'test' }].to_json)
    assert_equal [{ 'test' => 'test' }].to_json, @connection.doql('test')
    assert_requested req
  end

  def test_get_hosts
    req = stub_request(:post, format('%s://%s/services/data/v1.0/query/', @connection.scheme, @connection.host)).to_return(status: 200, body: @csv_string_host)
    assert_equal @array_host, @connection.get_hosts('10.75.1.1')
    assert_requested req
  end

  def test_get_hosts_by_ip
    req = stub_request(:post, format('%s://%s/services/data/v1.0/query/', @connection.scheme, @connection.host)).to_return(status: 200, body: @csv_string_host)
    assert_equal @array_host, @connection.get_hosts_by_ip('10.75.1.1')
    assert_requested req
  end

  def test_get_host_by_mac
    req = stub_request(:post, format('%s://%s/services/data/v1.0/query/', @connection.scheme, @connection.host)).to_return(status: 200, body: @csv_string_host)
    assert_equal @array_host, @connection.get_host_by_mac('a2:cd:f8:e9:90:eb')
    assert_requested req
  end

  def test_get_host_by_mac_empty
    req = stub_request(:post, format('%s://%s/services/data/v1.0/query/', @connection.scheme, @connection.host)).to_return(status: 200, body: '[]')
    assert_equal [], @connection.get_host_by_mac('a2:cd:f8:e9:90:eb')
    assert_requested req
  end

  def test_get_subnets
    req = stub_request(:post, format('%s://%s/services/data/v1.0/query/', @connection.scheme, @connection.host)).to_return(status: 200, body: @csv_string_subnet)
    assert_equal @array_subnet, @connection.get_subnets
    assert_requested req
  end

  def test_get_subnet
    req = stub_request(:post, format('%s://%s/services/data/v1.0/query/', @connection.scheme, @connection.host)).to_return(status: 200, body: @csv_string_subnet)
    assert_equal @array_subnet, @connection.get_subnet('10.75.1.0')
    assert_requested req
  end

  def test_get_subnet_empty
    req = stub_request(:post, format('%s://%s/services/data/v1.0/query/', @connection.scheme, @connection.host)).to_return(status: 200, body: '[]')
    assert_equal nil, @connection.get_subnet('10.75.1.0')
    assert_requested req
  end

  def test_get_next_ip
    @connection.expects(:get_subnet).returns(@array_subnet)
    req = stub_request(:get,
                       format('%s://%s/api/1.0/suggest_ip/?end_range=10.75.1.21&start_range=10.75.1.20&subnet_id=1',
                       @connection.scheme,
                       @connection.host)).to_return(status: 200, body: @ip_suggest_output)
    assert_equal '10.75.1.20', @connection.get_next_ip('10.75.1.0', '10.75.1.20', '10.75.1.21')
    assert_requested req
  end

  def test_get_next_ip_empty
    @connection.expects(:get_subnet).returns(nil)
    req = stub_request(:get, format('%s://%s/api/1.0/suggest_ip/?end_range=&start_range=&subnet_id=', @connection.scheme, @connection.host)).to_return(status: 200, body: @ip_suggest_output)
    assert_equal nil, @connection.get_next_ip('10.75.1.0', nil, nil)
    assert_not_requested req
  end
end
