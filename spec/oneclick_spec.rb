require 'spec_helper'
require 'vault_helper'

describe WebpayRails::Responses::InitInscription do
  let(:email) { 'john.doe@mail.com' }
  let(:username) { 'john' }
  let(:return_url) { 'http://localhost:3000/tbkonclick?option=return' }
  let!(:init_inscription_params) { { email: email, username: username, return_url: return_url } }

  context 'when all is ok' do
    let!(:inscription) { Order::Oneclick.init_inscription(init_inscription_params) }

    it { expect(inscription).to be_kind_of(WebpayRails::Responses::InitInscription) }

    describe '.token' do
      it { expect(inscription.token).not_to be_blank }
    end

    describe '.url_webpay' do
      it { expect(inscription.url_webpay).not_to be_blank }
    end
  end

  context 'when not' do
    it { expect { Order::Oneclick.init_inscription(init_inscription_params.merge(return_url: '')) }.to raise_error(WebpayRails::RequestFailed) }
    pending 'should raise WebpayRails::InvalidCertificate'
  end
end


describe WebpayRails::Responses::Authorization do
  context 'when all is ok' do
    #before(:all) { @inscription = Order::Oneclick.finish_inscription({ token: '' }) }
    #before(:all) { @authorization = Order::Oneclick.authorize({ username: '', tbk_user: '', amount: 0, order_id: '' }) }

    describe '.token' do
      pending 'should not be blank'
    end

    describe '.url' do
      pending 'should not be blank'
    end
  end

  context 'when not' do
    it { expect { Order::Oneclick.finish_inscription({ token: 'asd' }) }.to raise_error(WebpayRails::RequestFailed) }
    it { expect { Order::Oneclick.authorize({ username: '', tbk_user: '', amount: 0, order_id: '' }) }.to raise_error(WebpayRails::RequestFailed) }
    pending 'should raise WebpayRails::InvalidCertificate'
  end
end

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

describe 'Oneclick order flow' do
  let(:email) { 'john.doe@mail.com' }
  let(:username) { 'john' }

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
