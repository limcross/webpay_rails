require 'rails'
require 'active_support/concern'

require 'signer'
require 'savon'
require 'nokogiri'
require 'base64'
require 'digest/sha1'
require 'openssl'

require 'webpay_rails/version'
require 'webpay_rails/errors'
require 'webpay_rails/vault'
require 'webpay_rails/soap'
require 'webpay_rails/soap_normal'
require 'webpay_rails/soap_nullify'
require 'webpay_rails/verifier'
require 'webpay_rails/transaction'
require 'webpay_rails/transaction_result'
require 'webpay_rails/nullified'
require 'webpay_rails/railites'

module WebpayRails
  autoload :Base, 'webpay_rails/base'

  class << self
    attr_accessor :logger
  end

  def self.extended(base)
    base.include WebpayRails::Base

    super
  end
end
