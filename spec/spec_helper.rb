require 'bundler'

Bundler.require :default, :development

require 'capybara/rspec'

Combustion.initialize! :active_record, :action_controller, :action_view

require 'rspec/rails'
require 'capybara/rails'

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(
    app,
    browser: :firefox,
    desired_capabilities: Selenium::WebDriver::Remote::Capabilities.firefox(marionette: false)
  )
end

Capybara.default_driver = :selenium
Capybara.default_max_wait_time = 10

require 'webpay_rails'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end
