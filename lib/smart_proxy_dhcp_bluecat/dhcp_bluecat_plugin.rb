module Proxy::DHCP::BlueCat
  class Plugin < ::Proxy::Provider
    plugin :dhcp_bluecat, ::Proxy::DHCP::BlueCat::VERSION

    validate_presence :scheme, :verify, :host, :parent_block, :view_name, :config_id, :config_name, :server_id, :username, :password

    requires :dhcp, '>= 1.16'

    load_classes ::Proxy::DHCP::BlueCat::PluginConfiguration
    load_dependency_injection_wirings ::Proxy::DHCP::BlueCat::PluginConfiguration

    load_validators :scheme_validator => ::Proxy::DHCP::BlueCat::SchemeValidator,
                    :verify_validator => ::Proxy::DHCP::BlueCat::VerifyValidator,
                    :host_validator => ::Proxy::DHCP::BlueCat::HostValidator,
                    :parent_block_validator => ::Proxy::DHCP::BlueCat::parent_blockValidator,
                    :view_name_validator => ::Proxy::DHCP::BlueCat::view_nameValidator,
                    :config_id_validator => ::Proxy::DHCP::BlueCat::config_idValidator,
                    :config_name_validator => ::Proxy::DHCP::BlueCat::config_nameValidator,
                    :server_id_validator => ::Proxy::DHCP::BlueCat::server_idValidator,
                    :username_validator => ::Proxy::DHCP::BlueCat::UsernameValidator,
                    :password_validator => ::Proxy::DHCP::BlueCat::PasswordValidator

    validate :scheme, :scheme_validator => true
    validate :verify, :verify_validator => true
    validate :host, :host_validator => true
    validate :parent_block, :parent_block_validator => true
    validate :view_name, :view_name_validator => true
    validate :config_id, :config_id_validator => true
    validate :config_name, :config_name_validator => true
    validate :server_id, :server_id_validator => true
    validate :username, :username_validator => true
    validate :password, :password_validator => true
  end
end
