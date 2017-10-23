class Order::Oneclick < ActiveRecord::Base
  extend WebpayRails
  include Orderable
  include UniversallyUniqueIdentifiable

  self.table_name = 'orders'

  webpay_rails(
    commerce_code: 597020000547,
    private_key: Rails.root.join('vendor/vault/597020000547.key').to_s,
    public_cert: Rails.root.join('vendor/vault/597020000547.crt').to_s,
    webpay_cert: Rails.root.join('vendor/vault/tbk.pem').to_s
  )

  scope :created_on, ->(at) { where(created_at: at) }

  # Identificador único de la compra generado por el comercio.
  # Debe ser timestamp [yyyymmddhhMMss] + un correlativo de tres dígitos.
  # Ej: Para la tercera transacción realizada el día 15 de julio de 2011 a las
  # 11:55:50 la orden de compra sería: 20110715115550003.
  def buy_order_for_transbank_oneclick
    order = Order::Oneclick.created_on(created_at).first!
    time = created_at.strftime("%Y%m%d%H%M%S")
    offset = (id - order.id + 1).to_s.rjust(3, '0')
    time + offset
  end
end
