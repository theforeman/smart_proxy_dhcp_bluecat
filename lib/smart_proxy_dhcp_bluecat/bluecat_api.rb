require 'httparty'
require 'ipaddress'
require 'json'

class BlueCat
  include ::Proxy::Log
  @@token = ''
  attr_reader :scheme, :verify, :host, :parent_block, :view_name, :config_name, :config_id, :server_id, :username, :password
  def initialize(scheme, verify, host, parent_block, view_name, config_name, config_id, server_id, username, password)
    @scheme = scheme
    @verify = verify
    @host = host
    @parent_block = parent_block
    @view_name = view_name
    @config_id = config_id
    @config_name = config_name
    @server_id = server_id
    @username = username
    @password = password
    # @@token=rest_login()
  end

  def rest_login
    # login to bam, parse the session token
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
    @@token = token[0].to_s
  end

  def rest_logout
    # logout from bam,
    logger.debug('BAM Logout ')
    response = HTTParty.get(format('%s://%s/Services/REST/v1/logout', @scheme, @host),
                            headers: { 'Authorization' => 'BAMAuthToken: ' + @@token, 'Content-Type' => 'application/json' },
                            verify: @verify)
    if response.code != 200
      logger.error('BAM Logout Failed. HTTP' + response.code.to_s + ' ' + response.body.to_s)
    end
  end

  def rest_get(endpoint, querystring)
    # wrapper function to for rest get requests
    logger.debug('BAM GET ' + endpoint + '?' + querystring)

    response = HTTParty.get(format('%s://%s/Services/REST/v1/%s?%s', @scheme, @host, endpoint, querystring),
                              headers: { 'Authorization' => 'BAMAuthToken: ' + @@token, 'Content-Type' => 'application/json' },
                              verify: @verify)
    # Session propably expired, refresh it and do the request again
    if response.code == 401
      rest_login
      response = HTTParty.get(format('%s://%s/Services/REST/v1/%s?%s', @scheme, @host, endpoint, querystring),
                                headers: { 'Authorization' => 'BAMAuthToken: ' + @@token, 'Content-Type' => 'application/json' },
                                verify: @verify)
    end
    if response.code != 200
      logger.error('BAM GET Failed. HTTP' + response.code.to_s + ' ' + response.body.to_s)
      return nil
    else
      return response.body
    end
  end

  def rest_post(endpoint, querystring)
    # wrapper function to for rest post requests
    logger.debug('BAM POST ' + endpoint + '?' + querystring)
    response = HTTParty.post(format('%s://%s/Services/REST/v1/%s?%s', @scheme, @host, endpoint, querystring),
                              headers: { 'Authorization' => 'BAMAuthToken: ' + @@token, 'Content-Type' => 'application/json' },
                              verify: @verify
                            )
    # Session propably expired, refresh it and do the request again
    if response.code == 401
      rest_login
      response = HTTParty.post(format('%s://%s/Services/REST/v1/%s?%s', @scheme, @host, endpoint, querystring),
                               headers: { 'Authorization' => 'BAMAuthToken: ' + @@token, 'Content-Type' => 'application/json' },
                               verify: @verify)
    end
    if response.code != 200
      logger.error('BAM POST Failed. HTTP' + response.code.to_s + ' ' + response.body.to_s)
      return nil
    else
      return response.body
    end
  end

  def rest_put(endpoint, querystring)
    # wrapper function to for rest put requests
    logger.debug('BAM PUT ' + endpoint + '?' + querystring)
    response = HTTParty.put(format('%s://%s/Services/REST/v1/%s?%s', @scheme, @host, endpoint, querystring),
                            headers: { 'Authorization' => 'BAMAuthToken: ' + @@token, 'Content-Type' => 'application/json' },
                            verify: @verify)
    # Session propably expired, refresh it and do the request again
    if response.code == 401
      rest_login
      response = HTTParty.put(format('%s://%s/Services/REST/v1/%s?%s', @scheme, @host, endpoint, querystring),
                              headers: { 'Authorization' => 'BAMAuthToken: ' + @@token, 'Content-Type' => 'application/json' },
                              verify: @verify)
    end
    if response.code != 200
      logger.error('BAM PUT Failed. HTTP' + response.code.to_s + ' ' + response.body.to_s)
      return nil
    else
      return response.body
    end
  end

  def rest_delete(endpoint, querystring)
    # wrapper function to for rest delete requests
    logger.debug('BAM DELETE ' + endpoint + '?' + querystring)
    response = HTTParty.delete(format('%s://%s/Services/REST/v1/%s?%s', @scheme, @host, endpoint, querystring),
                               headers: { 'Authorization' => 'BAMAuthToken: ' + @@token, 'Content-Type' => 'application/json' },
                               verify: @verify)

    # Session propably expired, refresh it and do the request again
    if response.code == 401
      rest_login
      response = HTTParty.delete(format('%s://%s/Services/REST/v1/%s?%s', @scheme, @host, endpoint, querystring),
                                 headers: { 'Authorization' => 'BAMAuthToken: ' + @@token, 'Content-Type' => 'application/json' },
                                 verify: @verify)
    end
    if response.code != 200
      logger.error('BAM DELETE Failed. HTTP' + response.code.to_s + ' ' + response.body.to_s)
      return nil
    else
      return response.body
    end
  end

  def get_addressid_by_ip(ip)
    # helper function to get the object id of a ip by an ip address
    json = rest_get('getIP4Address', 'containerId=' + @config_id.to_s + '&address=' + ip)
    result = JSON.parse(json)
    return nil if result.empty?
    result['id'].to_s
  end

  def get_networkid_by_ip(ip)
    # helper function to get the object id of a subnet by an ip address
    logger.debug('BAM get_networkid_by_ip ' + ip)
    querystring = 'containerId=' + @config_id.to_s + '&type=IP4Network' + '&address=' + ip.to_s
    json = rest_get('getIPRangedByIP', querystring)
    result = JSON.parse(json)
    return nil if result.empty?
    result['id'].to_s
  end

  def get_network_by_ip(ip)
    # helper function to get the whole subnet informarions by an ip address
    logger.debug('BAM get_network_by_ip ' + ip)
    querystring = 'containerId=' + @config_id.to_s + '&type=IP4Network' + '&address=' + ip.to_s
    json = rest_get('getIPRangedByIP', querystring)
    result = JSON.parse(json)
    properties = parse_properties(result['properties'])
    properties['CIDR'].to_s
  end

  def  parse_properties(properties)
    # helper function to parse the properties scheme of bluecat into a hash
    # => properies: a string that contains properties for the object in attribute=value format, with each separated by a | (pipe) character.
    # For example, a host record object may have a properties field such as ttl=123|comments=my comment|.
    properties = properties.split('|')
    h = Hash.new('')
    properties.each do |property|
      h[property.split('=').first.to_s] = property.split('=').last.to_s
    end
    h
  end

  def add_host(options)
    # wrapper function to add the dhcp reservation and dns records

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
                                   '&options=AllowDuplicateHosts=true|')

    address_id = get_addressid_by_ip(options['ip'])

    # update the state of the ip from static to dhcp reserved
    rest_put('changeStateIP4Address', 'addressId=' + address_id +
                                      '&targetState=MAKE_DHCP_RESERVED' \
                                      '&macAddress=' + options['mac'])
    # deploy the config
    rest_post('deployServerConfig', 'serverId=' + @server_id.to_s + '&properties=services=DNS,DHCP')
    nil
  end

  def remove_host(ip)
    # wrapper function to remove a dhcp reservation and dns records
    # deploy the config, without a clean config the removal fails sometimes
    rest_post('deployServerConfig', 'serverId=' + @server_id.to_s + '&properties=services=DHCP,DNS')
    # remove the ip and depending records
    rest_delete('deleteDeviceInstance', 'configName=' + @config_name + '&identifier=' + ip)
    # deploy the config again
    rest_post('deployServerConfig', 'serverId=' + @server_id.to_s + '&properties=services=DHCP,DNS')
  end

  def get_next_ip(netadress, start_ip, _end_ip)
    # fetches the next free address in a subnet
    networkid = get_networkid_by_ip(netadress)

    start_ip = IPAddress.parse(netadress).first if start_ip.to_s.empty?

    properties = 'offset=' + start_ip.to_s + '|excludeDHCPRange=false'
    result = rest_get('getNextIP4Address', 'parentId=' + networkid.to_s + '&properties=' + properties)
    return nil if result.empty?
    result.tr('"', '')
  end

  def get_subnets
    # fetches all subnets under the parent_block
    json = rest_get('getEntities', 'parentId=' + @parent_block.to_s + '&type=IP4Network&start=0&count=10000')
    results = JSON.parse(json)
    subnets = []
    results.each do |result|
      properties = parse_properties(result['properties'])
      net = IPAddress.parse(properties['CIDR'])
      opts = { routers: [properties['gateway']] }
      subnets.push(::Proxy::DHCP::Subnet.new(net.address, net.netmask, opts))
    end
    subnets.compact
  end

  def find_mysubnet(subnet_address)
    # fetches a subnet by its network address
    net =  IPAddress.parse(get_network_by_ip(subnet_address))
    subnet = ::Proxy::DHCP::Subnet.new(net.address, net.netmask)
    subnet
  end

  def get_hosts(network_address)
    # fetches all dhcp reservations in a subnet
    netid = get_networkid_by_ip(network_address)
    net =  IPAddress.parse(get_network_by_ip(network_address))
    subnet = ::Proxy::DHCP::Subnet.new(net.address, net.netmask)

    json = rest_get('getNetworkLinkedProperties', 'networkId=' + netid.to_s)
    results = JSON.parse(json)

    hosts = []
    results.each do |result|
      properties = parse_properties(result['properties'])

      # Static Addresses and Gateway are not needed here
      # if properties.length() >= 4
      #  if properties["state"] == "Gateway" or properties["state"] == "Static"
      #    address = properties[0].split("=").last()
      #    macAddress = "00:00:00:00:00:00"
      #    hosttag = properties[3].split("=").last().split(":")
      #    name = hosttag[1] + "." + hosttag[3]
      #    opts = {:hostname => name}
      #    hosts.push(Proxy::DHCP::Reservation.new(name, address, macAddress, subnet, opts))
      #  end
      # end
      next unless properties.length >= 5
      next unless properties['state'] == 'DHCP Reserved'
      hosttag = properties['host'].split(':')
      name = hosttag[1] + '.' + hosttag[3]
      opts = { hostname: name }
      hosts.push(Proxy::DHCP::Reservation.new(name, properties['address'], properties['macAddress'].tr('-', ':'), subnet, opts))
    end
    hosts.compact
  end

  def get_hosts_by_ip(ip)
    # fetches a host by its ip
    hosts = []
    net =  IPAddress.parse(get_network_by_ip(ip))
    subnet = ::Proxy::DHCP::Subnet.new(net.address, net.netmask)
    ipid = get_addressid_by_ip(ip)
    return nil if ipid.to_s == '0'
    json = rest_get('getLinkedEntities', 'entityId=' + ipid + '&type=HostRecord&start=0&count=2')
    results = JSON.parse(json)
    logger.debug(results.to_s)

    if results.empty?
      # no host record on ip, fetch mac only
      json2 = rest_get('getIP4Address', 'containerId=' + @config_id.to_s + '&address=' + ip)
      result2 = JSON.parse(json2)
      properties2 = parse_properties(result2['properties'])
      mac_address = properties2['macAddress'].tr('-', ':')
      hosts.push(Proxy::DHCP::Reservation.new("", ip, mac_address, subnet, {}))
    else
      # host record on ip, return more infos
      results.each do |result|
        properties = parse_properties(result['properties'])
        opts = { hostname: properties['absoluteName'] }

        next unless properties['reverseRecord'].to_s == 'true'.to_s
        json2 = rest_get('getEntityById', 'id=' + ipid)
        result2 = JSON.parse(json2)
        properties2 = parse_properties(result2['properties'])
        mac_address = properties2['macAddress'].tr('-', ':')
        unless macAddress.empty?
          hosts.push(Proxy::DHCP::Reservation.new(properties['absoluteName'], ip, mac_address, subnet, opts))
        end
      end
    end
    hosts.compact
  end

  def get_host_by_mac(mac)
    # fetches all dhcp reservations by a mac
    json = rest_get('getMACAddress', 'configurationId=' + @config_id.to_s + '&macAddress=' + mac.to_s)
    result = JSON.parse(json)
    macid = result['id'].to_s
    return nil if macid == '0'
    json2 = rest_get('getLinkedEntities', 'entityId=' + macid + '&type=IP4Address&start=0&count=1')
    result2 = JSON.parse(json2)
    return nil if result2.empty?
    properties = parse_properties(result2[0]['properties'])
    host = get_hosts_by_ip(properties['address'])
    return nil if host.nil?
    host[0]
  end
end
