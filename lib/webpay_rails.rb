require 'active_support/concern'
require 'webpay_rails/version'

module WebpayRails
  autoload :Base,     'webpay_rails/base'
  autoload :Verifier, 'webpay_rails/verifier'

  def self.extended(base)
    base.include WebpayRails::Base
    base.include WebpayRails::Verifier

    super
  end

  begin
    require 'signer'
    require 'savon'

    require 'nokogiri'
    require 'base64'
    require 'digest/sha1'
    require 'openssl'
  rescue LoadError
  end
end
