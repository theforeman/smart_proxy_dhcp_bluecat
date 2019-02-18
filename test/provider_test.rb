require 'mocha'
require 'test_helper'
require 'dhcp_common/dhcp_common'
require 'dhcp_common/subnet'
require 'smart_proxy_dhcp_bluecat/dhcp_bluecat_main'

class BluecatProviderTest < Test::Unit::TestCase
  def setup
    @connection = Bluecat.new('10.10.10.10', 'https', true,
                               'user', 'password')
    @managed_subnets = nil

    @bluecat_api_response_subnet = {
      'network' => '192.168.42.0',
      'mask_bits' => '24'
    }
    @record = {
      'name' => 'test',
      'ip_address' => '192.168.42.1',
      'network' => '192.168.42.0',
      'mask_bits' => '24',
      'hwaddress' => '32e760a64061',
    }
    @subnet = Proxy::DHCP::Subnet.new('192.168.42.0', '255.255.255.0')
    @subnet2 = Proxy::DHCP::Subnet.new('192.168.42.0', '0.0.0.0')
    @provider = Proxy::DHCP::Bluecat::Provider.new(@connection, @managed_subnets)
    @reservation = Proxy::DHCP::Reservation.new('test', '192.168.42.1', '32:e7:60:a6:40:61', @subnet, {:hostname => 'test'})
    @reservation2 = Proxy::DHCP::Reservation.new('test', '192.168.42.1', '32:e7:60:a6:40:61', @subnet2, {:hostname => 'test'})
  end

  def test_cidr_to_ip_mask
    assert_equal '255.255.255.0', @provider.cidr_to_ip_mask('24'.to_i)
  end

  def test_build_reservation
    assert_equal @reservation, @provider.build_reservation(@record)
  end

  def test_build_reservation_without_name
    record = @record.select{|x| x != 'name'}
    assert_equal nil, @provider.build_reservation(record)
  end

  def test_build_reservation_without_ip
    record = @record.select{|x| x != 'ip_address'}
    assert_raises(Proxy::Validations::Error) { @provider.build_reservation(record) }
  end

  def test_build_reservation_without_network
    record = @record.select{|x| x != 'network'}
    assert_raises(Proxy::Validations::Error) { @provider.build_reservation(record) }
  end

  def test_build_reservation_without_mask
    record = @record.select{|x| x != 'mask_bits'}
    assert_equal @reservation2, @provider.build_reservation(record)
  end

  def test_build_reservation_without_hwaddress
    record = @record.select{|x| x != 'hwaddress'}
    assert_equal nil, @provider.build_reservation(record)
  end

  def test_build_reservation_empty
    assert_equal nil, @provider.build_reservation({})
  end

  def test_subnets
    @connection.expects(:get_subnets).returns([@bluecat_api_response_subnet])
    assert_equal [@subnet], @provider.subnets
  end

  def test_subnets_empty
    @connection.expects(:get_subnets).returns([])
    assert_equal [], @provider.subnets
  end

  def test_all_hosts
    @connection.expects(:get_hosts).returns([@record])
    assert_equal [@reservation], @provider.all_hosts(nil)
  end

  def test_unused_ip
    ip = {'ip_address' => '192.168.42.1'}
    @connection.expects(:get_next_ip).returns(ip)
    assert_equal ip, @provider.unused_ip(nil, nil, nil, nil)
  end

  def test_find_records_by_ip
    @connection.expects(:get_hosts_by_ip).returns([@record])
    assert_equal [@reservation], @provider.find_records_by_ip(nil, nil)
  end

  def test_find_records_by_ip_empty
    @connection.expects(:get_hosts_by_ip).returns([])
    assert_equal [], @provider.find_records_by_ip(nil, nil)
  end

  def test_find_record_by_mac
    @connection.expects(:get_host_by_mac).returns([@record])
    assert_equal @reservation, @provider.find_record_by_mac(nil, nil)
  end

  def test_find_record_by_mac_empty
    @connection.expects(:get_host_by_mac).returns([])
    assert_equal nil, @provider.find_record_by_mac(nil, nil)
  end

  def test_add_record
    @connection.expects(:add_host).returns(nil)
    assert_equal nil, @provider.add_record(nil)
  end

  def test_del_record
    @connection.expects(:remove_host).returns(nil)
    assert_equal nil, @provider.del_record(@reservation)
  end

end
