module WebpayRails
  class Railties < ::Rails::Railtie
    initializer 'Rails logger' do
      WebpayRails.rails_logger = Rails.logger
    end
  end
end
