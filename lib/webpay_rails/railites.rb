module WebpayRails
  class Railties < ::Rails::Railtie
    initializer 'Rails logger' do
      WebpayRails.logger = Rails.logger
    end
  end
end
