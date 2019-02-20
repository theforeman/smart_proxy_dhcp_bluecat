class ::Proxy::DHCP::BlueCat::ModuleLoader < ::Proxy::DefaultModuleLoader
  def log_provider_settings(settings)
    super(settings)
    logger.warn('http is used for connection to BlueCat address manager') if settings[:scheme] != 'https'
  end
end
