require 'spec_helper'
require 'vault_helper'

describe WebpayRails do
  before(:all) { @webpay_rails_params = { commerce_code: COMMERCE_CODE,
                                          private_key: PRIVATE_KEY,
                                          webpay_cert: WEBPAY_CERT,
                                          public_cert: PUBLIC_CERT } }

  describe WebpayRails::Base do
    it { expect{ Order::Blank.webpay_rails(@webpay_rails_params.except(:commerce_code)) }.to raise_error(WebpayRails::MissingCommerceCode) }
    it { expect{ Order::Blank.webpay_rails(@webpay_rails_params.except(:private_key)) }.to raise_error(WebpayRails::MissingPrivateKey) }
    it { expect{ Order::Blank.webpay_rails(@webpay_rails_params.except(:webpay_cert)) }.to raise_error(WebpayRails::MissingWebpayCertificate) }
    it { expect{ Order::Blank.webpay_rails(@webpay_rails_params.except(:public_cert)) }.to raise_error(WebpayRails::MissingPublicCertificate) }
    it { expect{ Order::Blank.webpay_rails(@webpay_rails_params.merge(private_key: '', public_cert: '', webpay_cert: '')) }.to raise_error(WebpayRails::FileNotFound) }
    it { expect{ Order::Blank.webpay_rails(@webpay_rails_params.merge(environment: :other)) }.to raise_error(WebpayRails::InvalidEnvironment) }
  end
end
