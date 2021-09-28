require 'dhcp_common/server'

module Proxy
  module DHCP
    module BlueCat
      # this class handles commuincation from foreman
      class Provider < ::Proxy::DHCP::Server
        include Proxy::Log
        include Proxy::Util

        attr_reader :connection
        def initialize(connection, managed_subnets)
          @connection = connection
          @managed_subnets = managed_subnets
          super('bluecat', managed_subnets, nil)
        end

        # returns all subnets
        def subnets
          logger.debug('START subnets')
          subnets = @connection.subnets
          logger.debug('END subnets')
          logger.debug('Returned: ' + subnets.class.to_s + ': ' + subnets.to_s)
          subnets
        end

        # returns all hosts in a subnet
        # in bluecat leases and hosts are the same
        def all_hosts(network_address)
          logger.debug('START all_hosts with network_address: ' + network_address.to_s)
          hosts = @connection.hosts(network_address)
          logger.debug('END all_hosts with network_address: ' + network_address.to_s)
          logger.debug('Returned: ' + hosts.class.to_s + ': ' + hosts.to_s)
          hosts
        end

        # returns all leases in a subnet
        # in bluecat leases and hosts are the same
        def all_leases(network_address)
          logger.debug('START all_leases with network_address: ' + network_address.to_s)
          hosts = @connection.hosts(network_address)
          logger.debug('END all_leases with network_address: ' + network_address.to_s)
          logger.debug('Returned: ' + hosts.class.to_s + ': ' + hosts.to_s)
          hosts
        end

        # returns the next free ip in a subnet
        def unused_ip(subnet, mac_address, from_ip_address, to_ip_address)
          logger.debug('START unused_ip with subnet: ' + subnet.to_s + ' mac_address: ' + mac_address.to_s + ' from_ip_address: ' + from_ip_address.to_s + ' to_ip_address: ' + to_ip_address.to_s)
          ip = @connection.next_ip(subnet, from_ip_address, to_ip_address)
          logger.debug('END unused_ip with subnet: ' + subnet.to_s + ' mac_address: ' + mac_address.to_s + ' from_ip_address: ' + from_ip_address.to_s + ' to_ip_address: ' + to_ip_address.to_s)
          logger.debug('Returned: ' + ip.class.to_s + ': ' + ip.to_s)
          ip
        end

        # returns a record
        # foreman calls this method with a ip or a mac address
        def find_record(subnet_address, address)
          logger.debug('START find_record with subnet_address: ' + subnet_address.to_s + ' address: ' + address.to_s)
          records = if IPAddress.valid?(address)
                      find_records_by_ip(subnet_address, address)
                    else
                      find_record_by_mac(subnet_address, address)
                    end
          logger.debug('END find_record with subnet_address: ' + subnet_address.to_s + ' address: ' + address.to_s)
          logger.debug('Returned: ' + records.class.to_s + ': ' + records.to_s)
          return [] if records.nil?
          records
        end

        # returns a record based on a ip address
        def find_records_by_ip(subnet_address, ip)
          logger.debug('START find_records_by_ip with subnet_address: ' + subnet_address.to_s + ' ip: ' + ip.to_s)
          records = @connection.hosts_by_ip(ip)
          logger.debug('END find_records_by_ip with subnet_address: ' + subnet_address.to_s + ' ip: ' + ip.to_s)
          logger.debug('Returned: ' + records.class.to_s + ': ' + records.to_s)
          return [] if records.nil?
          records
        end

        # returns a record based on a mac address
        def find_record_by_mac(subnet_address, mac_address)
          logger.debug('START find_record_by_mac with subnet_address: ' + subnet_address.to_s + ' mac_address: ' + mac_address.to_s)
          record = @connection.host_by_mac_and_subnet(subnet_address, mac_address)
          logger.debug('END find_record_by_mac with subnet_address: ' + subnet_address.to_s + ' mac_address: ' + mac_address.to_s)
          logger.debug('Returned: ' + record.class.to_s + ': ' + record.to_s)
          record
        end

        # returns a subnet based on a subnet address
        def find_subnet(subnet_address)
          logger.debug('START find_subnet with subnet_address: ' + subnet_address.to_s)
          net = @connection.find_mysubnet(subnet_address)
          logger.debug('END find_subnet with subnet_address: ' + subnet_address.to_s)
          logger.debug('Returned: ' + net.class.to_s + ': ' + net.to_s)
          net
        end

        # returns a subnet based on a subnet address
        def get_subnet(subnet_address)
          logger.debug('START get_subnet with subnet_address: ' + subnet_address.to_s)
          net = @connection.find_mysubnet(subnet_address)
          logger.debug('END get_subnet with subnet_address: ' + subnet_address.to_s)
          logger.debug('Returned: ' + net.class.to_s + ': ' + net.to_s)
          net
        end

        # adds a host record
        def add_record(options)
          logger.debug('START add_record with options: ' + options.to_s)
          @connection.add_host(options)
          logger.debug('END add_record with options: ' + options.to_s)
        end

        # removes a host record
        def del_record(record)
          logger.debug('START del_record with record: ' + record.to_s)
          if record.empty?
            logger.debug('record empty, nothing to do')
          else
            @connection.remove_host(record.ip)
          end
          logger.debug('END del_record with record: ' + record.to_s)
        end
      end
    end
  end
end
