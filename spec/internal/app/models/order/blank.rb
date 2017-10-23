class Order::Blank < ActiveRecord::Base
  extend WebpayRails
  include Orderable
  include UniversallyUniqueIdentifiable

  self.table_name = 'orders'
end
