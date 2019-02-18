require 'dhcp_common/server'

module Proxy::DHCP::BlueCat
  class Provider < ::Proxy::DHCP::Server
    include Proxy::Log
    include Proxy::Util

    attr_reader :connection
    def initialize(connection, managed_subnets)
      @connection = connection
      @managed_subnets = managed_subnets
      super('bluecat', managed_subnets, nil)
    end

    def subnets()
      logger.info("START subnets")
      subnets =  @connection.get_subnets()
      logger.info("END subnets")
      logger.info("Returned: " + subnets.class.to_s + ": " + subnets.to_s)
      return subnets
    end

    def all_hosts(network_address)
      logger.info("START all_hosts with network_address: " + network_address.to_s)
      hosts = @connection.get_hosts(network_address)
      logger.info("END all_hosts with network_address: " + network_address.to_s)
      logger.info("Returned: " + hosts.class.to_s + ": " + hosts.to_s)
      return hosts
    end

    def all_leases(network_address)
      logger.info("START all_leases with network_address: " + network_address.to_s)
      hosts = @connection.get_hosts(network_address)
      logger.info("END all_leases with network_address: " + network_address.to_s)
      logger.info("Returned: " + hosts.class.to_s + ": " + hosts.to_s)
      return hosts
    end

    def unused_ip(subnet, mac_address, from_ip_address, to_ip_address)
      logger.info("START unused_ip with subnet: " + subnet.to_s + " mac_address: " + mac_address.to_s + " from_ip_address: " + from_ip_address.to_s + " to_ip_address: " + to_ip_address.to_s )
      ip = @connection.get_next_ip(subnet, from_ip_address, to_ip_address)
      logger.info("END unused_ip with subnet: " + subnet.to_s + " mac_address: " + mac_address.to_s + " from_ip_address: " + from_ip_address.to_s + " to_ip_address: " + to_ip_address.to_s )
      logger.info("Returned: " + ip.class.to_s + ": " + ip.to_s)
      return ip
    end


    def find_record(subnet_address, address)
      logger.info("START find_record with subnet_address: " + subnet_address.to_s + " address: " + address.to_s)
      if IPAddress.valid?(address)
        records = find_records_by_ip(subnet_address, address)
      else
        records = find_record_by_mac(subnet_address, address)
      end
      logger.info("END find_record with subnet_address: " + subnet_address.to_s + " address: " + address.to_s)
      logger.info("Returned: " + records.class.to_s + ": " + records.to_s)
      return [] if records.nil?
      return records
    end

    def find_records_by_ip(subnet_address, ip)
      logger.info("START find_records_by_ip with subnet_address: " + subnet_address.to_s + " ip: " + ip.to_s)
      records = @connection.get_hosts_by_ip(ip)
      logger.info("END find_records_by_ip with subnet_address: " + subnet_address.to_s + " ip: " + ip.to_s)
      logger.info("Returned: " + records.class.to_s + ": " + records.to_s)
      return [] if records.nil?
      return records
    end

    def find_record_by_mac(subnet_address, mac_address)
      logger.info("START find_record_by_mac with subnet_address: " + subnet_address.to_s + " mac_address: " + mac_address.to_s)
      record = @connection.get_host_by_mac(mac_address)
      logger.info("END find_record_by_mac with subnet_address: " + subnet_address.to_s + " mac_address: " + mac_address.to_s)
      logger.info("Returned: " + record.class.to_s + ": " + record.to_s)
      return record
    end

    def find_subnet(subnet_address)
      logger.info("START find_subnet with subnet_address: " + subnet_address.to_s)
      net = @connection.find_mysubnet(subnet_address)
      logger.info("END find_subnet with subnet_address: " + subnet_address.to_s)
      logger.info("Returned: " + net.class.to_s + ": " + net.to_s)
      return net
    end

    def get_subnet(subnet_address)
      logger.info("START get_subnet with subnet_address: " + subnet_address.to_s)
      net = @connection.find_mysubnet(subnet_address)
      logger.info("END get_subnet with subnet_address: " + subnet_address.to_s)
      logger.info("Returned: " + net.class.to_s + ": " + net.to_s)
      return net
    end

    def add_record(options)
      logger.info("START add_record with options: " + options.to_s)
      @connection.add_host(options)
      logger.info("END add_record with options: " + options.to_s)
    end


    def del_record(record)
      logger.info("START del_record with record: " + record.to_s)
      if record.empty?
        logger.info("record empty, nothing to do")
      else
        @connection.remove_host(record.ip)
      end
      logger.info("END del_record with record: " + record.to_s)
    end

  end
end
