require 'active_support/concern'
require 'webpay_rails/version'
require 'webpay_rails/errors'
require 'webpay_rails/verifier'
require 'webpay_rails/transaction'
require 'webpay_rails/result'

module WebpayRails
  autoload :Base,     'webpay_rails/base'

  def self.extended(base)
    base.include WebpayRails::Base

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
