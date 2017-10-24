require 'spec_helper'
require 'vault_helper'

describe 'Inscription flow' do
  let(:email) { 'john.doe@mail.com' }
  let(:username) { 'john' }

  before(:each) { visit new_oneclick_inscription_path }

  context 'when it accepted' do
    it 'it is sent to the success page' do
      # Rails app
      fill_in(id: 'user_email', with: email)
      fill_in(id: 'user_username', with: username)
      find('input[type=submit]').click

      # Webpay
      fill_in('TBK_NUMERO_TARJETA', with: '4051885600446623')
      fill_in('TBK_CVV', with: '123')
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

      # Rails app
      expect(page).to have_content('Success inscription')
    end
  end

  context 'when it rejected' do
    it 'it is sent to the failure page' do
      # Rails app
      fill_in(id: 'user_email', with: email)
      fill_in(id: 'user_username', with: username)
      find('input[type=submit]').click

      # Webpay
      fill_in('TBK_NUMERO_TARJETA', with: '4051885600446623')
      fill_in('TBK_CVV', with: '123')
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
      expect(page).to have_content('Failed inscription')
    end
  end
end

describe 'Authorization flow' do
  before(:each) { visit new_oneclick_order_path }

  context 'when it accepted' do
    it 'it is sent to the success page' do
      # Rails app
      fill_in(id: 'order_oneclick_amount', with: '1000')
      find('input[type=submit]').click

      # Webpay
      accept_alert if page.driver.options[:browser] == :firefox

      # Rails app
      expect(page).to have_content('Success transaction')
    end
  end
end

describe 'Reverse order' do
  before(:all) { @buy_order = Order::Oneclick.approved.last!.buy_order_for_transbank_oneclick }

  context 'when all is ok' do
    before(:all) { @result = Order::Oneclick.reverse(buy_order: @buy_order) }

    it { expect(@result).to be_kind_of(WebpayRails::Responses::Reverse) }
    it { expect(@result.success?).to be_truthy }

    describe '.return' do
      it { expect(@result.return).not_to be_blank }
    end
  end

  context 'when not' do
    it { expect { Order::Oneclick.reverse(buy_order: '') }.to raise_error(WebpayRails::RequestFailed) }
    pending 'should raise WebpayRails::InvalidCertificate'
  end
end

describe 'Unsubscribe' do
  before(:all) { @tbk_user = User.first!.tbk_user }
  before(:all) { @username = 'john' }

  context 'when all is ok' do
    before(:all) { @result = Order::Oneclick.remove_user(tbk_user: @tbk_user, username: @username) }

    it { expect(@result).to be_kind_of(WebpayRails::Responses::RemoveUser) }
    it { expect(@result.success?).to be_truthy }

    describe '.return' do
      it { expect(@result.return).not_to be_blank }
    end
  end

  context 'when not' do
    it { expect { Order::Oneclick.remove_user(tbk_user: '', username: @username) }.to raise_error(WebpayRails::RequestFailed) }
    pending 'should raise WebpayRails::InvalidCertificate'
  end
end
