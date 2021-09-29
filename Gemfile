source "https://rubygems.org"
gemspec

group :development do
  gem "rake"
  gem "test-unit"
  gem "mocha"
  gem "smart_proxy", github: "theforeman/smart-proxy", branch: "develop"
  gem "webmock"
  gem "rubocop"
  gem "rubocop-performance"
  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.6.0")
    gem "rufo"
  end
end

gem "httparty"
gem "ipaddress"
