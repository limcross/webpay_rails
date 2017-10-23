require 'spec_helper'
require 'vault_helper'

describe WebpayRails::Responses::InitTransaction do
  let(:amount) { 1000 }
  let(:buy_order) { SecureRandom.uuid.first(30).delete!('-') }
  let(:session_id) { 'aj2h4kj2' }
  let(:return_url) { 'http://localhost:3000/tbknormal?option=return' }
  let(:final_url) { 'http://localhost:3000/tbknormal?option=final' }
  let(:init_transaction_params) do
    { amount: amount,
      buy_order: buy_order,
      session_id: session_id,
      return_url: return_url,
      final_url: final_url }
  end
  context 'when all is ok' do
    let!(:transaction) { Order::Normal.init_transaction(init_transaction_params) }

    it { expect(transaction).to be_kind_of(WebpayRails::Responses::InitTransaction) }

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

  context 'when not' do
    it { expect { Order::Normal.init_transaction(init_transaction_params.merge(return_url: '', final_url: '')) }.to raise_error(WebpayRails::RequestFailed) }
    it { expect { Order::Normal.init_transaction(init_transaction_params.merge(amount: 0)) }.to raise_error(WebpayRails::RequestFailed) }
    it { expect { Order::NormalInvalid.init_transaction(init_transaction_params) }.to raise_error(WebpayRails::InvalidCertificate) }
  end
end

describe WebpayRails::Responses::TransactionResult do
  context 'when all is ok' do
    describe '.buy_order' do
      pending 'should not be blank'
    end

    describe '.session_id' do
      # pending 'should not be blank' NOTE: In fact it can
    end

    describe '.accounting_date' do
      pending 'should not be blank'
    end

    describe '.transaction_date' do
      pending 'should not be blank'
    end

    describe '.vci' do
      pending 'should not be blank'
    end

    describe '.url_redirection' do
      pending 'should not be blank'
    end

    describe '.card_number' do
      pending 'should not be blank'
    end

    describe '.card_expiration_date' do
      # pending 'should not be blank' NOTE: In fact Webpay returns blank
    end

    describe '.authorization_code' do
      pending 'should not be blank'
    end

    describe '.payment_type_code' do
      pending 'should not be blank'
    end

    describe '.response_code' do
      pending 'should not be blank'
    end

    describe '.amount' do
      pending 'should not be blank'
    end

    describe '.shares_number' do
      pending 'should not be blank'
    end

    describe '.commerce_code' do
      pending 'should not be blank'
    end

    describe '.approved?' do
      pending 'should be truthy'
    end
  end

  context 'when not' do
    it { expect { Order::Normal.init_transaction(token: 'asd') }.to raise_error(WebpayRails::RequestFailed) }
    pending 'should raise WebpayRails::InvalidCertificate'
  end
end

describe 'Normal debit payment flow' do
  before(:each) { visit new_normal_order_path }

  context 'when it accepted' do
    it 'it is sent to the success page' do
      # Rails app
      fill_in(id: 'order_normal_amount', with: '1000')
      find('input[type=submit]').click

      # Webpay
      find('input#TBK_TIPO_TARJETA[value=DEBIT_CARD]').set(true)
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
      fill_in(id: 'order_normal_amount', with: '1000')
      find('input[type=submit]').click

      # Webpay
      find('input#TBK_TIPO_TARJETA[value=DEBIT_CARD]').set(true)
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
      fill_in(id: 'order_normal_amount', with: '1000')
      find('input[type=submit]').click

      # Webpay
      click_button('button3')
      accept_alert if page.driver.options[:browser] == :firefox

      # Rails app
      expect(page).to have_content('Failed transaction')
    end
  end
end

describe 'Normal credit (without shares) payment flow' do
  before(:each) { visit '/' }

  context 'when it accepted' do
    it 'it is sent to the success page' do
      # Rails app
      fill_in(id: 'order_normal_amount', with: '1000')
      find('input[type=submit]').click

      # Webpay
      find('input#TBK_TIPO_TARJETA[value=CREDIT_CARD]').set(true)
      fill_in('TBK_NUMERO_TARJETA', with: '4051885600446623')
      fill_in('TBK_CVV', with: '123')
      shares_radio = find('input#TBK_TIPO_PAGO597020000541_noshares')
      expect(shares_radio).to be_checked
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
      fill_in(id: 'order_normal_amount', with: '1000')
      find('input[type=submit]').click

      # Webpay
      find('input#TBK_TIPO_TARJETA[value=CREDIT_CARD]').set(true)
      fill_in('TBK_NUMERO_TARJETA', with: '4051885600446623')
      fill_in('TBK_CVV', with: '123')
      shares_radio = find('input#TBK_TIPO_PAGO597020000541_noshares')
      expect(shares_radio).to be_checked
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
end
