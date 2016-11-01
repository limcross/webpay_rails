require 'bundler'

Bundler.require :default, :development

require 'capybara/rspec'

Combustion.initialize! :active_record, :action_controller, :action_view

require 'rspec/rails'
require 'capybara/rails'

if ENV['CAPYBARA_DRIVER'].try(:to_sym) == :poltergeist
  require 'capybara/poltergeist'
  Capybara.default_driver = :poltergeist
else
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(
      app,
      browser: :firefox,
      desired_capabilities: Selenium::WebDriver::Remote::Capabilities.firefox(marionette: false)
    )
  end

  Capybara.default_driver = :selenium
end
Capybara.default_max_wait_time = 10

require 'coveralls'

Coveralls.wear!

require 'webpay_rails'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end
