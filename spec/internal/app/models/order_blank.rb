class OrderBlank < ActiveRecord::Base
  include UniversallyUniqueIdentifiable
  extend WebpayRails
end
