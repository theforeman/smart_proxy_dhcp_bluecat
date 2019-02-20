require 'test_helper'
require 'smart_proxy_dhcp_bluecat/settings_validator'

class SchemeValidatorTest < Test::Unit::TestCase
  def setup
    @validator = ::Proxy::DHCP::Bluecat::SchemeValidator.new(:dhcp_bluecat, :scheme, nil, nil)
  end

  def test_should_pass_when_record_type_is_http
    assert @validator.validate!(scheme: 'http')
  end

  def test_should_pass_when_record_type_is_https
    assert @validator.validate!(scheme: 'https')
  end

  def test_should_raise_exception_when_record_type_is_unrecognised
    assert_raises(::Proxy::Error::ConfigurationError) { @validator.validate!(scheme: '') }
  end
end
