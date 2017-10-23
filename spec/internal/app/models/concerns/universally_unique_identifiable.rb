module UniversallyUniqueIdentifiable
  extend ActiveSupport::Concern

  included do
    before_create :set_uuid
  end

  def set_uuid
    assign_attributes(uuid: SecureRandom.uuid)
  end
end
