require 'spec_helper'
require 'vault_helper'

describe WebpayRails do
  let(:amount) { 1000 }
  let(:buy_order) { rand(1111111..9999999) }
  let(:session_id) { 'aj2h4kj2' }
  let(:return_url) { 'http://localhost:3000/tbknormal?option=return' }
  let(:final_url) { 'http://localhost:3000/tbknormal?option=final' }
  let(:init_transaction_params) do
    { amount: amount, buy_order: buy_order, session_id: session_id,
      return_url: return_url, final_url: final_url }
  end
  let(:webpay_rails_params) do
    { commerce_code: COMMERCE_CODE, private_key: PRIVATE_KEY,
      webpay_cert: WEBPAY_CERT, public_cert: PUBLIC_CERT }
  end

  describe WebpayRails::Base do
    it { expect{ OrderBlank.webpay_rails(webpay_rails_params.except(:commerce_code)) }.to raise_error(WebpayRails::MissingCommerceCode) }
    it { expect{ OrderBlank.webpay_rails(webpay_rails_params.except(:private_key)) }.to raise_error(WebpayRails::MissingPrivateKey) }
    it { expect{ OrderBlank.webpay_rails(webpay_rails_params.except(:webpay_cert)) }.to raise_error(WebpayRails::MissingWebpayCertificate) }
    it { expect{ OrderBlank.webpay_rails(webpay_rails_params.except(:public_cert)) }.to raise_error(WebpayRails::MissingPublicCertificate) }
    it { expect{ OrderBlank.webpay_rails(webpay_rails_params.merge(private_key: '', public_cert: '', webpay_cert: '')) }.to raise_error(WebpayRails::FileNotFound) }
    it { expect{ OrderBlank.webpay_rails(webpay_rails_params.merge(environment: :other)) }.to raise_error(WebpayRails::InvalidEnvironment) }
  end

  describe WebpayRails::Transaction do
    describe 'when all is ok' do
      let(:transaction) { Order.init_transaction(init_transaction_params) }

      it { expect(transaction).to be_kind_of(WebpayRails::Transaction) }

      describe '.token' do
        it { expect(transaction.token).not_to be_blank }
      end

      describe '.url' do
        it { expect(transaction.url).not_to be_blank }
      end

      describe '.success?' do
        it { expect(transaction.success?).to be_truthy }
      end
    end

    describe 'when not' do
      it { expect { Order.init_transaction(init_transaction_params.merge(return_url: '', final_url: '')) }.to raise_error(WebpayRails::RequestFailed) }
      it { expect { Order.init_transaction(init_transaction_params.merge(amount: 0)) }.to raise_error(WebpayRails::RequestFailed) }
      it { expect { OrderInvalid.init_transaction(init_transaction_params) }.to raise_error(WebpayRails::InvalidCertificate) }
    end
  end

  describe WebpayRails::TransactionResult do
    pending 'comming soon'
  end

  describe WebpayRails::TransactionNullified do
    pending 'comming soon'
  end

  describe 'Normal debit payment flow' do
    before(:each) { visit '/' }

    context 'when it accepted' do
      it 'it is sent to the success page' do
        # Rails app
        fill_in(id: 'order_amount', with: '1000')
        find('input[type=submit]').click

        # Webpay
        find(:css, 'input#TBK_TIPO_TARJETA[value=DEBIT_CARD]').set(true)
        select('TEST COMMERCE BANK', from: 'TBK_BANCO')
        fill_in('TBK_NUMERO_TARJETA', with: '12345678')
        click_button('button')

        # Demo Bank
        within_frame('transicion') do
          fill_in('rutClient', with: '111111111')
          fill_in('passwordClient', with: '123')
          find('input[type=submit]').click

          # It is not necessary because it is already selected by default
          # select('Aceptar', from: 'vci')
          find('input[type=submit]').click
        end

        # Webpay
        accept_alert if page.driver.options[:browser] == :firefox
        click_button('button4')
        accept_alert if page.driver.options[:browser] == :firefox

        # Rails app
        expect(page).to have_content('Success transaction')
      end
    end

    context 'when it rejected' do
      it 'it is sent to the failure page' do
        # Rails app
        fill_in(id: 'order_amount', with: '1000')
        find('input[type=submit]').click

        # Webpay
        find(:css, 'input#TBK_TIPO_TARJETA[value=DEBIT_CARD]').set(true)
        select('TEST COMMERCE BANK', from: 'TBK_BANCO')
        fill_in('TBK_NUMERO_TARJETA', with: '12345678')
        click_button('button')

        # Demo Bank
        within_frame('transicion') do
          fill_in('rutClient', with: '111111111')
          fill_in('passwordClient', with: '123')
          find('input[type=submit]').click

          select('Rechazar', from: 'vci')
          find('input[type=submit]').click
        end

        # Webpay
        accept_alert if page.driver.options[:browser] == :firefox

        # Rails app
        expect(page).to have_content('Failed transaction')
      end
    end

    context 'when click on the "Anular" button' do
      it 'it is sent to the failure page' do
        # Rails app
        fill_in(id: 'order_amount', with: '1000')
        find('input[type=submit]').click

        # Webpay
        click_button('button3')
        accept_alert if page.driver.options[:browser] == :firefox

        # Rails app
        expect(page).to have_content('Failed transaction')
      end
    end
  end
end
