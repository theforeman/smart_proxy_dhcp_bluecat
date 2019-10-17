module ::Proxy::DHCP::BlueCat
  class SchemeValidator < ::Proxy::PluginValidators::Base
    def validate!(settings)
      return true if ['http', 'https'].include?(settings[:scheme])
      raise ::Proxy::Error::ConfigurationError, "Setting 'scheme' can be set to either 'http' or 'https'"
    end
  end
  class VerifyValidator < ::Proxy::PluginValidators::Base
    def validate!(settings)
      return true if [true, false].include?(settings[:verify])
      raise ::Proxy::Error::ConfigurationError, "Setting 'verify' can be set to either 'true' or 'false' (bool)"
    end
  end
  class HostValidator < ::Proxy::PluginValidators::Base
    def validate!(settings)
      return true if ['http', 'https'].include?(settings[:scheme])
      raise ::Proxy::Error::ConfigurationError, "Setting 'scheme' can be set to either 'http' or 'https'"
    end
  end
  class ParentBlockValidator < ::Proxy::PluginValidators::Base
    def validate!(settings)
      return true if settings[:parent_block].is_a?(Integer)
      raise ::Proxy::Error::ConfigurationError, "Setting 'parent_block' must be (integer)"
    end
  end
  class ViewNameValidator < ::Proxy::PluginValidators::Base
    def validate!(settings)
      return true if settings[:view_name].is_a?(String)
      raise ::Proxy::Error::ConfigurationError, "Setting 'view_name' must be (string)"
    end
  end
  class ConfigIdValidator < ::Proxy::PluginValidators::Base
    def validate!(settings)
      return true if settings[:config_id].is_a?(Integer)
      raise ::Proxy::Error::ConfigurationError, "Setting 'parent_block' must be (integer)"
    end
  end
  class ConfigNameValidator < ::Proxy::PluginValidators::Base
    def validate!(settings)
      return true if settings[:config_name].is_a?(String)
      raise ::Proxy::Error::ConfigurationError, "Setting 'config_name' must be (string)"
    end
  end
  class ServerIdValidator < ::Proxy::PluginValidators::Base
    def validate!(settings)
      return true if settings[:server_id].is_a?(Integer)
      raise ::Proxy::Error::ConfigurationError, "Setting 'server_id' must be (integer)"
    end
  end
  class UsernameValidator < ::Proxy::PluginValidators::Base
    def validate!(settings)
      return true if settings[:username].is_a?(String)
      raise ::Proxy::Error::ConfigurationError, "Setting 'username' must be (string)"
    end
  end
  class PasswordValidator < ::Proxy::PluginValidators::Base
    def validate!(settings)
      return true if settings[:password].is_a?(String)
      raise ::Proxy::Error::ConfigurationError, "Setting 'password' must be (string)"
    end
  end
end
