# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require "webpay_rails/version"

Gem::Specification.new do |s|
  s.platform      = Gem::Platform::RUBY
  s.name          = "webpay_rails"
  s.version       = WebpayRails::VERSION
  s.summary       = "WebpayRails is an easy solution for integrate Transbank Webpay in Rails applications."
  s.description   = s.summary
  s.authors       = ["Sebastián Orellana"]
  s.email         = ["limcross@gmail.com"]
  s.homepage      = "https://github.com/limcross/webpay_rails"
  s.license       = "MIT"
  s.require_paths = ["lib"]
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.required_ruby_version = '>= 2.2.2'

  s.add_dependency 'signer', '~> 1.4.3'
  s.add_dependency 'savon', '~> 2'
  s.add_dependency 'nokogiri', '~> 1.6', '>= 1.6.7.2'
  s.add_dependency 'activesupport', '>= 3.2'
  s.add_dependency 'railties', '>= 4.1.0', '< 5.1'

  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'activerecord', '>= 3.2'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rake'

end
