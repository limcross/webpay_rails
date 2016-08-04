Gem::Specification.new do |gem|
  gem.name	= 'libwebpay'
	gem.version = '1.1.0'
	gem.date = '2015-04-15'
	gem.summary = "This software was created for easy integration of ecommerce portals with Transbank Webpay solution."
	gem.description = gem.summary
	gem.authors = ["Allware Ltda."]
  gem.homepage = 'http://www.allware.cl'
	gem.email = 'soporte@transbank.com'
	gem.files = ["lib/libwebpay.rb","lib/verifier.rb"]
	gem.license = 'GNU LGPL'
  gem.add_dependency('savon', '~> 2')
  gem.add_runtime_dependency 'nokogiri', '~> 1.6', '>= 1.6.7.2'
end