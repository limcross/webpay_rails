require 'bundler'

Bundler.require :default, :development

require 'capybara/rspec'

Combustion.initialize! :active_record, :action_controller, :action_view

require 'rspec/rails'
require 'capybara/rails'

Capybara.register_driver :chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w[window-size=1024,768] }
  )

  Capybara::Selenium::Driver.new app, browser: :chrome,
                                      desired_capabilities: capabilities
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w[headless disable-gpu window-size=1024,768] }
  )

  Capybara::Selenium::Driver.new app, browser: :chrome,
                                      desired_capabilities: capabilities
end

driver_name = (ENV['CAPYBARA_DRIVER'] || 'headless_chrome').to_sym
Capybara.javascript_driver = driver_name
Capybara.default_driver = driver_name
Capybara.default_max_wait_time = 10

require 'coveralls'

Coveralls.wear!

require 'webpay_rails'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end
