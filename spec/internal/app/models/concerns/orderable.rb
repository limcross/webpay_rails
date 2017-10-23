module Orderable
  extend ActiveSupport::Concern

  included do
    enum status: [:created, :approved, :failed, :canceled, :expired, :pending,
                  :refunded]

    scope :approved, -> { where(status: self.statuses[:approved]) }
    scope :normal_selling, -> { where(tbk_payment_type_code: 'VN') }
  end
end
