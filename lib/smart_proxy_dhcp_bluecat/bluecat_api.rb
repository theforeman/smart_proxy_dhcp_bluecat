require "httparty"
require "ipaddress"
require "json"

class BlueCat
    include ::Proxy::Log
    @@token=""
    attr_reader :scheme, :verify, :host, :parentBlock, :viewName, :configName, :configId, :serverId, :username, :password
    def initialize(scheme, verify, host, parentBlock, viewName, configName, configId, serverId, username, password)
      @scheme = scheme
      @verify = verify
      @host = host
      @parentBlock = parentBlock
      @viewName = viewName
      @configId = configId
      @configName = configName
      @serverId = serverId
      @username = username
      @password = password
      #@@token=rest_login()
    end

    def rest_login()
      logger.debug ("BAM Login " + @scheme + " " +  @host + " " + @username + " " + @password)
      response  = HTTParty.get("%s://%s/Services/REST/v1/login?username=%s&password=%s" % [@scheme, @host, @username, @password], {
        :verify => @verify,
        "Content-Type" => "text/plain"
      })
      if response.code != 200
        logger.error ("BAM Login Failed. HTTP" +  response.code.to_s + " " + response.body.to_s)
      end
      body = response.body.to_s
      token = body.match(/BAMAuthToken:\s+(\S+)/).captures

      logger.debug ("BAM Login Body " +  response.body)
      logger.debug ("BAM Login Token " +  token[0].to_s)
      @@token=token[0].to_s
    end
    def rest_logout()
      logger.debug ("BAM Logout " +  @@token)
      response = HTTParty.get("%s://%s/Services/REST/v1/logout" % [@scheme, @host], {
        :headers => { "Authorization" => "BAMAuthToken: " + @@token, "Content-Type" => "application/json"},
        :verify => @verify
      })
      if response.code != 200
        logger.error ("BAM Logout Failed. HTTP" +  response.code.to_s + " " + response.body.to_s)
      end
    end

    def rest_get(endpoint, querystring)
      logger.debug ("BAM GET " + endpoint + "?" + querystring)

      response = HTTParty.get("%s://%s/Services/REST/v1/%s?%s" % [@scheme, @host, endpoint, querystring], {
                                :headers => { "Authorization" => "BAMAuthToken: " + @@token, "Content-Type" => "application/json"},
                                :verify => @verify
                           })
      if response.code == 401
        rest_login()
        response = HTTParty.get("%s://%s/Services/REST/v1/%s?%s" % [@scheme, @host, endpoint, querystring], {
                                  :headers => { "Authorization" => "BAMAuthToken: " + @@token, "Content-Type" => "application/json"},
                                  :verify => @verify
                             })
      end
      if response.code != 200
        logger.error ("BAM GET Failed. HTTP" +  response.code.to_s + " " + response.body.to_s)
        return nil
      else
        return response.body
      end
    end

    def rest_post(endpoint, querystring)
      logger.debug ("BAM POST " + endpoint + "?" + querystring)
      response = HTTParty.post("%s://%s/Services/REST/v1/%s?%s" % [@scheme, @host, endpoint, querystring], {
                                :headers => { "Authorization" => "BAMAuthToken: " + @@token, "Content-Type" => "application/json"},
                                :verify => @verify
                              })
      if response.code == 401
        rest_login()
        response = HTTParty.post("%s://%s/Services/REST/v1/%s?%s" % [@scheme, @host, endpoint, querystring], {
                                  :headers => { "Authorization" => "BAMAuthToken: " + @@token, "Content-Type" => "application/json"},
                                  :verify => @verify
                                })
      end
      if response.code != 200
        logger.error ("BAM POST Failed. HTTP" +  response.code.to_s + " " + response.body.to_s)
        return nil
      else
        return response.body
      end
    end

    def rest_put(endpoint, querystring)
      logger.debug ("BAM PUT " + endpoint + "?" + querystring)
      response = HTTParty.put("%s://%s/Services/REST/v1/%s?%s" % [@scheme, @host, endpoint, querystring], {
                                :headers => { "Authorization" => "BAMAuthToken: " + @@token, "Content-Type" => "application/json"},
                                :verify => @verify
                              })
      if response.code == 401
        rest_login()
        response = HTTParty.put("%s://%s/Services/REST/v1/%s?%s" % [@scheme, @host, endpoint, querystring], {
                                  :headers => { "Authorization" => "BAMAuthToken: " + @@token, "Content-Type" => "application/json"},
                                  :verify => @verify
                                })
      end
      if response.code != 200
        logger.error ("BAM PUT Failed. HTTP" +  response.code.to_s + " " + response.body.to_s)
        return nil
      else
        return response.body
      end
    end

    def rest_delete(endpoint, querystring)
      logger.debug ("BAM DELETE " + endpoint + "?" + querystring)
      response = HTTParty.delete("%s://%s/Services/REST/v1/%s?%s" % [@scheme, @host, endpoint, querystring], {
                                  :headers => { "Authorization" => "BAMAuthToken: " + @@token, "Content-Type" => "application/json"},
                                  :verify => @verify
                              })
      if response.code == 401
        rest_login()
        response = HTTParty.delete("%s://%s/Services/REST/v1/%s?%s" % [@scheme, @host, endpoint, querystring], {
                                    :headers => { "Authorization" => "BAMAuthToken: " + @@token, "Content-Type" => "application/json"},
                                    :verify => @verify
                                })
      end
      if response.code != 200
        logger.error ("BAM DELETE Failed. HTTP" +  response.code.to_s + " " + response.body.to_s)
        return nil
      else
        return response.body
      end
    end

    def get_addressid_by_ip(ip)
      json = rest_get("getIP4Address", "containerId=" + @configId.to_s + "&address=" + ip )
      result = JSON.parse(json)
      return nil if result.empty?
      return result['id'].to_s
    end
    def get_networkid_by_ip(ip)
      logger.debug ("BAM get_networkid_by_ip " + ip)
      querystring = "containerId=" + @configId.to_s + "&type=IP4Network" + "&address=" + ip.to_s
      json = rest_get("getIPRangedByIP", querystring)
      result = JSON.parse(json)
      return nil if result.empty?
      return result['id'].to_s
    end
    def get_network_by_ip(ip)
      logger.debug ("BAM get_network_by_ip " + ip)
      querystring = "containerId=" + @configId.to_s + "&type=IP4Network" + "&address=" + ip.to_s
      json = rest_get("getIPRangedByIP", querystring)
      result = JSON.parse(json)
      properties = parse_properties(result["properties"])
      return properties["CIDR"].to_s
    end

    def  parse_properties(properties)
      properties = properties.split("|")
      h = Hash.new("")
      properties.each do |property|
        h[property.split("=").first().to_s] = property.split("=").last().to_s
      end
      return h
    end

    def add_host(options)

      rest_post("addDeviceInstance", "configName=" + @configName +
                                     "&ipAddressMode=PASS_VALUE" +
                                     "&ipEntity=" + options['ip'] +
                                     "&viewName=" + @viewName +
                                     "&zoneName=" + options['hostname'].split('.', 2).last +
                                     "&deviceName=" + options['hostname'] +
                                     "&recordName=" + options['hostname'] +
                                     "&macAddressMode=PASS_VALUE" +
                                     "&macEntity=" + options['mac'] +
                                     "&options=AllowDuplicateHosts=true|"
                                   )

      addressId  = get_addressid_by_ip(options['ip'] )

      rest_put("changeStateIP4Address", "addressId=" + addressId +
                                        "&targetState=MAKE_DHCP_RESERVED" +
                                        "&macAddress=" + options['mac']
                                        )
      rest_post("deployServerConfig", "serverId=" + @serverId.to_s + "&properties=services=DNS,DHCP")
      return nil
    end

    def remove_host(ip)
      rest_post("deployServerConfig", "serverId=" + @serverId.to_s + "&properties=services=DHCP,DNS")
      rest_delete("deleteDeviceInstance", "configName=" + @configName +  "&identifier=" + ip)
    end

    def get_next_ip(netadress, start_ip, end_ip)
      networkid = get_networkid_by_ip(netadress)

      if start_ip.to_s.empty?
        start_ip = IPAddress.parse(netadress).first
      end

      properties = "offset=" + start_ip.to_s + "|excludeDHCPRange=false"
      result = rest_get("getNextIP4Address", "parentId=" + networkid.to_s + "&properties=" + properties)
      return nil if result.empty?
      return result.tr('"', '')
    end

    def get_subnets()
      json = rest_get("getEntities", "parentId=" + @parentBlock.to_s + "&type=IP4Network&start=0&count=10000")
      results = JSON.parse(json)
      subnets=[]
      results.each do |result|
        properties = parse_properties(result["properties"])
        net = IPAddress.parse(properties["CIDR"])
        opts = {:routers => [properties["gateway"]]}
        subnets.push(::Proxy::DHCP::Subnet.new(net.address, net.netmask, opts))
      end
      return subnets.compact()
    end

    def find_mysubnet(subnet_address)
      net =  IPAddress.parse(get_network_by_ip(subnet_address))
      subnet = ::Proxy::DHCP::Subnet.new(net.address, net.netmask)
      return subnet
    end

    def get_hosts(network_address)
      netid = get_networkid_by_ip(network_address)
      net =  IPAddress.parse(get_network_by_ip(network_address))
      subnet = ::Proxy::DHCP::Subnet.new(net.address, net.netmask)

      json = rest_get("getNetworkLinkedProperties", "networkId=" + netid.to_s)
      results = JSON.parse(json)

      hosts = []
      results.each do |result|
        properties = parse_properties(result["properties"])

        #Static Addresses and Gateway are not needed here
        #if properties.length() >= 4
        #  if properties["state"] == "Gateway" or properties["state"] == "Static"
        #    address = properties[0].split("=").last()
        #    macAddress = "00:00:00:00:00:00"
        #    hosttag = properties[3].split("=").last().split(":")
        #    name = hosttag[1] + "." + hosttag[3]
        #    opts = {:hostname => name}
        #    hosts.push(Proxy::DHCP::Reservation.new(name, address, macAddress, subnet, opts))
        #  end
        #end
        if properties.length() >= 5
          if properties["state"] == "DHCP Reserved"
            hosttag = properties["host"].split(":")
            name = hosttag[1] + "." + hosttag[3]
            opts = {:hostname => name}
            hosts.push(Proxy::DHCP::Reservation.new(name, properties["address"], properties["macAddress"].tr('-', ':'), subnet, opts))
          end
        end
      end
      return hosts.compact()
    end

    def get_hosts_by_ip(ip)
        net =  IPAddress.parse(get_network_by_ip(ip))
        subnet = ::Proxy::DHCP::Subnet.new(net.address, net.netmask)
        ipid = get_addressid_by_ip(ip)
        return nil if ipid.to_s == "0"
        json = rest_get("getLinkedEntities", "entityId=" + ipid + "&type=HostRecord&start=0&count=2")
        results = JSON.parse(json)
        return nil if results.empty?
        hosts = []
        results.each do |result|
          properties = parse_properties(result["properties"])
            opts = {:hostname => properties["absoluteName"]}

            if properties["reverseRecord"].to_s== "true".to_s
              json2 = rest_get("getEntityById", "id=" + ipid)
              result2 = JSON.parse(json2)
              properties2 = parse_properties(result2["properties"])
              macAddress = properties2["macAddress"].tr('-', ':')
              unless macAddress.empty?
                hosts.push(Proxy::DHCP::Reservation.new(properties["absoluteName"], ip, macAddress, subnet, opts))
              end
            end
        end
        return hosts.compact
    end

    def get_host_by_mac(mac)
      json = rest_get("getMACAddress", "configurationId=" + @configId.to_s + "&macAddress=" + mac.to_s )
      result = JSON.parse(json)
      macid = result["id"].to_s
      return nil if macid == "0"
      json2 = rest_get("getLinkedEntities", "entityId=" + macid + "&type=IP4Address&start=0&count=1")
      result2 = JSON.parse(json2)
      return nil if result2.empty?
      properties = parse_properties(result2[0]["properties"])
      host = get_hosts_by_ip(properties["address"])
      return nil if host.nil?
      return host[0]
    end

end
