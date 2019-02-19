module Proxy::DHCP::BlueCat
  class PluginConfiguration
    def load_classes
      require 'dhcp_common/dhcp_common'
      require 'smart_proxy_dhcp_bluecat/bluecat_api'
      require 'smart_proxy_dhcp_bluecat/dhcp_bluecat_main'
    end

    def load_dependency_injection_wirings(c, settings)


      c.dependency :connection, (lambda do
                                  BlueCat.new(
                                    settings[:scheme],
                                    settings[:verify],
                                    settings[:host],
                                    settings[:parent_block],
                                    settings[:view_name],
                                    settings[:config_name],
                                    settings[:config_id],
                                    settings[:server_id],
                                    settings[:username],
                                    settings[:password])
                                  end)



      c.dependency :dhcp_provider, (lambda do
                                      ::Proxy::DHCP::BlueCat::Provider.new(
                                        c.get_dependency(:connection),
                                        settings[:subnets])
                                      end)
    end
  end
end
