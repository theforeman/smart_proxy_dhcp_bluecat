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
                                    settings[:parentBlock],
                                    settings[:viewName],
                                    settings[:configName],
                                    settings[:configId],
                                    settings[:serverId],
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
