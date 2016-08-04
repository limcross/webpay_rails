# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require "secret_id/version"

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "webpay_rails"
  s.version     = WebpayRails::VERSION
  s.summary     = "This software was created for easy integration of ecommerce portals with Transbank Webpay solution."
  s.description = s.summary
  s.authors     = ["Sebastián Orellana"]
  s.email       = ["limcross@gmail.com"]
  s.homepage    = "https://github.com/limcross/webpay_rails"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency('savon', '~> 2')
  s.add_runtime_dependency 'nokogiri', '~> 1.6', '>= 1.6.7.2'
end
