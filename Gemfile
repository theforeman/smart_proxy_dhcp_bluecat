source 'https://rubygems.org'
gemspec

group :development, :test  do
  gem 'rake'
  gem 'test-unit'
  gem 'mocha'
  gem 'smart_proxy', git: 'https://github.com/theforeman/smart-proxy', branch: 'develop'
  gem 'webmock'
  if RUBY_VERSION < '2.1'
    gem 'public_suffix', '< 3'
  else
    gem 'public_suffix'
  end
end

gem 'httparty'
gem 'ipaddress'
