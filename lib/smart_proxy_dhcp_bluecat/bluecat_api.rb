require 'httparty'
require 'ipaddress'
require 'json'

module Proxy
  module DHCP
    module BlueCat
      ##
      # This Class handles all commuincation to the bluecat address manager
      class BlueCatAPI
        include ::Proxy::Log

        # connection mode to the address manager. http or https
        attr_reader :scheme

        # validate ssl connection. true or false
        attr_reader :verify

        # fqdn or ip of your bluecat address manager
        attr_reader :host

        # id of the parent_block that holds the subnets that you want to use
        attr_reader :parent_block

        # name of your dns view
        attr_reader :view_name

        # Name of your Bluecat configuration
        attr_reader :config_name

        # id of your Bluecat configuration
        attr_reader :config_id

        # id of the server that holds your dhcp
        attr_reader :server_id

        # credentials of your api user
        attr_reader :username

        # credentials of your api user
        attr_reader :password

        class << self
          # contains the bluecat api token
          attr_accessor :token
        end

        def initialize(scheme, verify, host, parent_block, view_name, config_name, config_id, server_id, username, password)
          @scheme = scheme
          @verify = verify
          @host = host
          @parent_block = parent_block
          @view_name = view_name
          @config_name = config_name
          @config_id = config_id
          @server_id = server_id
          @username = username
          @password = password
        end

        # login to bam, parse the session token
        def rest_login
          logger.debug('BAM Login ' + @scheme + ' ' + @host + ' ')
          response = HTTParty.get(format('%s://%s/Services/REST/v1/login?username=%s&password=%s', @scheme, @host, @username, @password),
                                  headers: { 'Content-Type' => 'text/plain' },
                                  verify => @verify)
          if response.code != 200
            logger.error('BAM Login Failed. HTTP' + response.code.to_s + ' ' + response.body.to_s)
          end
          body = response.body.to_s
          token = body.match(/BAMAuthToken:\s+(\S+)/).captures

          logger.debug('BAM Login Body ' + response.body)
          logger.debug('BAM Login Token ' + token[0].to_s)
          self.class.token = token[0].to_s
        end

        # logout from bam
        def rest_logout
          logger.debug('BAM Logout ')
          response = HTTParty.get(format('%s://%s/Services/REST/v1/logout', @scheme, @host),
                                  headers: { 'Authorization' => 'BAMAuthToken: ' + self.class.token, 'Content-Type' => 'application/json' },
                                  verify: @verify)
          logger.error('BAM Logout Failed. HTTP' + response.code.to_s + ' ' + response.body.to_s) if response.code != 200
        end

        # wrapper function to for rest get requests
        def rest_get(endpoint, querystring)
          rest_login if self.class.token.nil?

          logger.debug('BAM GET ' + endpoint + '?' + querystring)

          response = HTTParty.get(format('%s://%s/Services/REST/v1/%s?%s', @scheme, @host, endpoint, querystring),
                                  headers: { 'Authorization' => 'BAMAuthToken: ' + self.class.token, 'Content-Type' => 'application/json' },
                                    verify: @verify)
          # Session propably expired, refresh it and do the request again
          if response.code == 401
            rest_login
            response = HTTParty.get(format('%s://%s/Services/REST/v1/%s?%s', @scheme, @host, endpoint, querystring),
                                    headers: { 'Authorization' => 'BAMAuthToken: ' + self.class.token, 'Content-Type' => 'application/json' },
                                      verify: @verify)
          end

          return response.body if response.code == 200
          logger.error('BAM GET Failed. HTTP' + response.code.to_s + ' ' + response.body.to_s)
        end

        # wrapper function to for rest post requests
        def rest_post(endpoint, querystring)
          logger.debug('BAM POST ' + endpoint + '?' + querystring)
          response = HTTParty.post(format('%s://%s/Services/REST/v1/%s?%s', @scheme, @host, endpoint, querystring),
                                   headers: { 'Authorization' => 'BAMAuthToken: ' + self.class.token, 'Content-Type' => 'application/json' },
                                    verify: @verify
                                  )
          # Session propably expired, refresh it and do the request again
          if response.code == 401
            rest_login
            response = HTTParty.post(format('%s://%s/Services/REST/v1/%s?%s', @scheme, @host, endpoint, querystring),
                                     headers: { 'Authorization' => 'BAMAuthToken: ' + self.class.token, 'Content-Type' => 'application/json' },
                                     verify: @verify)
          end
          return response.body if response.code == 200
          logger.error('BAM POST Failed. HTTP' + response.code.to_s + ' ' + response.body.to_s)
        end

        # wrapper function to for rest put requests
        def rest_put(endpoint, querystring)
          logger.debug('BAM PUT ' + endpoint + '?' + querystring)
          response = HTTParty.put(format('%s://%s/Services/REST/v1/%s?%s', @scheme, @host, endpoint, querystring),
                                  headers: { 'Authorization' => 'BAMAuthToken: ' + self.class.token, 'Content-Type' => 'application/json' },
                                  verify: @verify)
          # Session propably expired, refresh it and do the request again
          if response.code == 401
            rest_login
            response = HTTParty.put(format('%s://%s/Services/REST/v1/%s?%s', @scheme, @host, endpoint, querystring),
                                    headers: { 'Authorization' => 'BAMAuthToken: ' + self.class.token, 'Content-Type' => 'application/json' },
                                    verify: @verify)
          end
          return response.body if response.code == 200
          logger.error('BAM PUT Failed. HTTP' + response.code.to_s + ' ' + response.body.to_s)
        end

        # wrapper function to for rest delete requests
        def rest_delete(endpoint, querystring)
          logger.debug('BAM DELETE ' + endpoint + '?' + querystring)
          response = HTTParty.delete(format('%s://%s/Services/REST/v1/%s?%s', @scheme, @host, endpoint, querystring),
                                     headers: { 'Authorization' => 'BAMAuthToken: ' + self.class.token, 'Content-Type' => 'application/json' },
                                     verify: @verify)

          # Session propably expired, refresh it and do the request again
          if response.code == 401
            rest_login
            response = HTTParty.delete(format('%s://%s/Services/REST/v1/%s?%s', @scheme, @host, endpoint, querystring),
                                       headers: { 'Authorization' => 'BAMAuthToken: ' + self.class.token, 'Content-Type' => 'application/json' },
                                       verify: @verify)
          end
          return response.body if response.code == 200
          logger.error('BAM DELETE Failed. HTTP' + response.code.to_s + ' ' + response.body.to_s)
        end

        # helper function to get the object id of a ip by an ip address
        def get_addressid_by_ip(ip)
          json = rest_get('getIP4Address', 'containerId=' + @config_id.to_s + '&address=' + ip)
          result = JSON.parse(json)
          return nil if result.empty?
          result['id'].to_s
        end

        # helper function to get the object id of a subnet by an ip address
        def get_networkid_by_ip(ip)
          logger.debug('BAM get_networkid_by_ip ' + ip)
          querystring = 'containerId=' + @config_id.to_s + '&type=IP4Network' + '&address=' + ip.to_s
          json = rest_get('getIPRangedByIP', querystring)
          result = JSON.parse(json)
          return nil if result.empty?
          result['id'].to_s
        end

        # helper function to get the whole subnet informarions by an ip address
        def get_network_by_ip(ip)
          logger.debug('BAM get_network_by_ip ' + ip)
          querystring = 'containerId=' + @config_id.to_s + '&type=IP4Network' + '&address=' + ip.to_s
          json = rest_get('getIPRangedByIP', querystring)
          result = JSON.parse(json)
          properties = parse_properties(result['properties'])
          properties['CIDR'].to_s
        end

        # helper function to parse the properties scheme of bluecat into a hash
        #
        # properies: a string that contains properties for the object in attribute=value format, with each separated by a | (pipe) character.
        # For example, a host record object may have a properties field such as ttl=123|comments=my comment|.
        def parse_properties(properties)
          properties = properties.split('|')
          h = {}
          properties.each do |property|
            h[property.split('=').first.to_s] = property.split('=').last.to_s
          end
          h
        end

        # public
        # wrapper function to add the dhcp reservation and dns records
        def add_host(options)
          # add the ip and hostname and mac as static
          rest_post('addDeviceInstance', 'configName=' + @config_name +
                                         '&ipAddressMode=PASS_VALUE' \
                                         '&ipEntity=' + options['ip'] +
                                         '&viewName=' + @view_name +
                                         '&zoneName=' + options['hostname'].split('.', 2).last +
                                         '&deviceName=' + options['hostname'] +
                                         '&recordName=' + options['hostname'] +
                                         '&macAddressMode=PASS_VALUE' \
                                         '&macEntity=' + options['mac'] +
                                         '&options=AllowDuplicateHosts=true%7C')

          address_id = get_addressid_by_ip(options['ip'])

          # update the state of the ip from static to dhcp reserved
          rest_put('changeStateIP4Address', 'addressId=' + address_id +
                                            '&targetState=MAKE_DHCP_RESERVED' \
                                            '&macAddress=' + options['mac'])

          unless options['nextServer'].empty?
            rest_post('addDHCPClientDeploymentOption', 'entityId=' + address_id.to_s + '&name=tftp-server-name' + "&value=" + options['nextServer'].to_s)
          end
          unless options['filename'].empty?
            rest_post('addDHCPClientDeploymentOption', 'entityId=' + address_id.to_s + '&name=boot-file-name' + "&value=" + options['filename'].to_s)
          end

          # deploy the config
          rest_post('deployServerConfig', 'serverId=' + @server_id.to_s + '&properties=services=DHCP')
          # lets wait a little bit for the complete dhcp deploy
          sleep 3
          rest_post('deployServerConfig', 'serverId=' + @server_id.to_s + '&properties=services=DNS')
          nil
        end

        # public
        # wrapper function to remove a ip record and depending dns records
        def remove_host(ip)
          ipid = get_addressid_by_ip(ip)
          json = rest_get('getLinkedEntities', 'entityId=' + ipid.to_s + '&type=HostRecord&start=0&count=2')
          results = JSON.parse(json)

          hosts = results.map do |result|
            rest_delete('delete', 'objectId=' + result['id'].to_s)
          end
          rest_delete('delete', 'objectId=' + ipid.to_s)

          rest_post('deployServerConfig', 'serverId=' + @server_id.to_s + '&properties=services=DHCP,DNS')
        end

        # public
        # fetches the next free address in a subnet
        # +end_ip not implemented+
        def next_ip(netadress, start_ip, end_ip)
          networkid = get_networkid_by_ip(netadress)

          start_ip = IPAddress.parse(netadress).first if start_ip.to_s.empty?

          properties = 'offset=' + start_ip.to_s + '%7CexcludeDHCPRange=false'
          result = rest_get('getNextIP4Address', 'parentId=' + networkid.to_s + '&properties=' + properties)
          return if result.empty?
          result.tr('"', '')
        end

        # public
        # fetches all subnets under the parent_block
        def subnets
          json = rest_get('getEntities', 'parentId=' + @parent_block.to_s + '&type=IP4Network&start=0&count=10000')
          results = JSON.parse(json)
          subnets = results.map do |result|
            properties = parse_properties(result['properties'])
            net = IPAddress.parse(properties['CIDR'])
            opts = { routers: [properties['gateway']] }

            if properties['gateway'].nil?
              logger.error("subnet issue: " + properties['CIDR'] + " skipped, due missing gateway in bluecat")
              next
            end

            ::Proxy::DHCP::Subnet.new(net.address, net.netmask, opts)
          end
          subnets.compact
        end

        # public
        # fetches a subnet by its network address
        def find_mysubnet(subnet_address)
          net = IPAddress.parse(get_network_by_ip(subnet_address))
          subnet = ::Proxy::DHCP::Subnet.new(net.address, net.netmask)
          subnet
        end

        # public
        # fetches all dhcp reservations in a subnet
        def hosts(network_address)
          netid = get_networkid_by_ip(network_address)
          net =  IPAddress.parse(get_network_by_ip(network_address))
          subnet = ::Proxy::DHCP::Subnet.new(net.address, net.netmask)

          json = rest_get('getNetworkLinkedProperties', 'networkId=' + netid.to_s)
          results = JSON.parse(json)

          hosts = results.map do |result|
            properties = parse_properties(result['properties'])

            ## Static Addresses and Gateway are not needed here
            ## But lets keep the logic to identify them
            # if properties.length() >= 4
            #  if properties["state"] == "Gateway" or properties["state"] == "Static"
            #    address = properties[0].split("=").last()
            #    macAddress = "00:00:00:00:00:00"
            #    hosttag = properties[3].split("=").last().split(":")
            #    name = hosttag[1] + "." + hosttag[3]
            #    opts = {:hostname => name}
            #    ::Proxy::DHCP::Reservation.new(name, address, macAddress, subnet, opts)
            #  end
            # end
            next unless properties.length >= 5
            next unless properties['state'] == 'DHCP Reserved'
            hosttag = properties['host'].split(':')
            name = hosttag[1] + '.' + hosttag[3]
            opts = { hostname: name }
            ::Proxy::DHCP::Reservation.new(name, properties['address'], properties['macAddress'].tr('-', ':'), subnet, opts)
          end
          hosts.compact
        end

        # public
        # fetches a host by its ip
        def hosts_by_ip(ip)
          hosts = []
          net =  IPAddress.parse(get_network_by_ip(ip))
          subnet = ::Proxy::DHCP::Subnet.new(net.address, net.netmask)
          ipid = get_addressid_by_ip(ip)
          return nil if ipid.to_s == '0'
          json = rest_get('getLinkedEntities', 'entityId=' + ipid + '&type=HostRecord&start=0&count=2')
          results = JSON.parse(json)

          if results.empty? || (results == "Link request is not supported")
            # no host record on ip, fetch mac only
            json2 = rest_get('getIP4Address', 'containerId=' + @config_id.to_s + '&address=' + ip)
            result2 = JSON.parse(json2)
            properties2 = parse_properties(result2['properties'])
            unless properties2['macAddress'].nil?
              mac_address = properties2['macAddress'].tr('-', ':')
              hosts.push(Proxy::DHCP::Reservation.new("", ip, mac_address, subnet, {}))
            end
          else
            # host record on ip, return more infos
            results.each do |result|
              properties = parse_properties(result['properties'])
              opts = { hostname: properties['absoluteName'] }

              next unless properties['reverseRecord'].to_s == 'true'.to_s
              json2 = rest_get('getEntityById', 'id=' + ipid)
              result2 = JSON.parse(json2)
              properties2 = parse_properties(result2['properties'])
              unless properties2['macAddress'].nil?
                mac_address = properties2['macAddress'].tr('-', ':')
                hosts.push(Proxy::DHCP::Reservation.new(properties['absoluteName'], ip, mac_address, subnet, opts))
              end
            end
          end
          hosts.compact
        end

        # public
        # fetches all dhcp reservations by a mac
        def host_by_mac(mac)
          json = rest_get('getMACAddress', 'configurationId=' + @config_id.to_s + '&macAddress=' + mac.to_s)
          result = JSON.parse(json)
          macid = result['id'].to_s
          return if macid == '0'
          json2 = rest_get('getLinkedEntities', 'entityId=' + macid + '&type=IP4Address&start=0&count=1')
          result2 = JSON.parse(json2)
          return if result2.empty?
          properties = parse_properties(result2[0]['properties'])
          host = hosts_by_ip(properties['address'])
          return if host.nil?
          host[0]
        end
      end
    end
  end
end
