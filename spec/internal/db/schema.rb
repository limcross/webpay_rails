ActiveRecord::Schema.define do
  create_table(:orders, force: true) do |t|
    t.string :uuid
    t.string :tbk_token_ws, index: true
    t.string :tbk_accounting_date
    t.string :tbk_buy_order
    t.string :tbk_card_number
    t.string :tbk_commerce_code
    t.string :tbk_authorization_code
    t.string :tbk_payment_type_code
    t.string :tbk_response_code
    t.string :tbk_transaction_date
    t.string :tbk_vci
    t.string :tbk_session_id
    t.string :tbk_card_expiration_date
    t.string :tbk_shares_number
    t.integer :amount
    t.integer :status, default: 0

    t.timestamps
  end
end
