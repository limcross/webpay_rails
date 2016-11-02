module UniversallyUniqueIdentifiable
  extend ActiveSupport::Concern

  included do
    before_create :set_uuid
  end

  def set_uuid
    assign_attributes(uuid: SecureRandom.uuid)
  end

  def buy_order_for_transbank
    uuid.first(30).delete!('-')
  end
end
