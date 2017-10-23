class Order::NormalInvalid < ActiveRecord::Base
  extend WebpayRails
  include Orderable
  include UniversallyUniqueIdentifiable

  self.table_name = 'orders'

  webpay_rails(
    commerce_code: 597020000541,
    private_key: Rails.root.join('vendor/vault/597020000541.key').to_s,
    public_cert: Rails.root.join('vendor/vault/597020000541.crt').to_s,
    webpay_cert: Rails.root.join('vendor/vault/597020000541.crt').to_s
  )
end
