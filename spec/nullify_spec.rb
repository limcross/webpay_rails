require 'spec_helper'
require 'vault_helper'

describe WebpayRails::Responses::TransactionNullify do
  before(:all) { @approved_order = Order::Normal.normal_selling.approved.first! }
  before(:all) do
    @nullify_params =
      {
        authorization_code: @approved_order.tbk_authorization_code,
        authorized_amount: @approved_order.amount,
        buy_order: @approved_order.tbk_buy_order,
        nullify_amount: @approved_order.amount
      }
  end

  context 'when all is ok' do
    before(:all) { @nullified_transaction = Order::Normal.nullify(@nullify_params) }

    it { expect(@nullified_transaction).to be_kind_of(WebpayRails::Responses::TransactionNullify) }

    describe '.token' do
      it { expect(@nullified_transaction.token).not_to be_blank }
    end

    describe '.authorization_code' do
      it { expect(@nullified_transaction.authorization_code).not_to be_blank }
    end

    describe '.authorization_date' do
      it { expect(@nullified_transaction.authorization_date).not_to be_blank }
    end

    describe '.balance' do
      it { expect(@nullified_transaction.balance).not_to be_blank }
    end

    describe '.nullified_amount' do
      it { expect(@nullified_transaction.nullified_amount).not_to be_blank }
    end
  end

  context 'when not' do
    it { expect { Order::Normal.nullify(@nullify_params.merge(nullify_amount: 0)) }.to raise_error(WebpayRails::RequestFailed) }
    pending 'should raise WebpayRails::InvalidCertificate'
  end
end
