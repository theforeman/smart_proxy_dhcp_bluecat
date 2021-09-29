source "https://rubygems.org"
gemspec

group :development do
  gem "mocha"
  gem "rake"
  gem "rubocop"
  gem "rubocop-performance"
  gem "rufo" if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.6.0")
  gem "smart_proxy", github: "theforeman/smart-proxy", branch: "develop"
  gem "test-unit"
  gem "webmock"
end

gem "httparty"
gem "ipaddress"
