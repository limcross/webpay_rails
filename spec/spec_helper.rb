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
  Capybara.register_driver :chrome do |app|
    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: { args: %w[window-size=1024,768] }
    )

    Capybara::Selenium::Driver.new app, browser: :chrome,
                                        desired_capabilities: capabilities
  end

  Capybara.default_driver = :chrome
end
Capybara.default_max_wait_time = 10

require 'coveralls'

Coveralls.wear!

require 'webpay_rails'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end
