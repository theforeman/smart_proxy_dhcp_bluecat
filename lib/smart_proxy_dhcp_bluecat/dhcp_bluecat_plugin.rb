module Proxy::DHCP::BlueCat
  class Plugin < ::Proxy::Provider
    plugin :dhcp_bluecat, ::Proxy::DHCP::BlueCat::VERSION

    validate_presence :scheme, :verify, :host, :parentBlock, :viewName, :configId, :configName, :serverId, :username, :password

    requires :dhcp, '>= 1.16'

    load_classes ::Proxy::DHCP::BlueCat::PluginConfiguration
    load_dependency_injection_wirings ::Proxy::DHCP::BlueCat::PluginConfiguration

    load_validators :scheme_validator => ::Proxy::DHCP::BlueCat::SchemeValidator,
                    :verify_validator => ::Proxy::DHCP::BlueCat::VerifyValidator,
                    :host_validator => ::Proxy::DHCP::BlueCat::HostValidator,
                    :parentBlock_validator => ::Proxy::DHCP::BlueCat::ParentBlockValidator,
                    :viewName_validator => ::Proxy::DHCP::BlueCat::ViewNameValidator,
                    :configId_validator => ::Proxy::DHCP::BlueCat::ConfigIdValidator,
                    :configName_validator => ::Proxy::DHCP::BlueCat::ConfigNameValidator,
                    :serverId_validator => ::Proxy::DHCP::BlueCat::ServerIdValidator,
                    :username_validator => ::Proxy::DHCP::BlueCat::UsernameValidator,
                    :password_validator => ::Proxy::DHCP::BlueCat::PasswordValidator

    validate :scheme, :scheme_validator => true
    validate :verify, :verify_validator => true
    validate :host, :host_validator => true
    validate :parentBlock, :parentBlock_validator => true
    validate :viewName, :viewName_validator => true
    validate :configId, :configId_validator => true
    validate :configName, :configName_validator => true
    validate :serverId, :serverId_validator => true
    validate :username, :username_validator => true
    validate :password, :password_validator => true
  end
end
