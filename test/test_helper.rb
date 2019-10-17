require 'test/unit'
require 'mocha/setup'

require 'smart_proxy_for_testing'

# create log directory in our (not smart-proxy) directory
FileUtils.mkdir_p File.dirname(Proxy::SETTINGS.log_file)

def fixture(name)
  File.read(File.expand_path("../fixtures/#{name}", __FILE__))
end
