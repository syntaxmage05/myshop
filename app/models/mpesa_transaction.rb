# frozen_string_literal: true

class MpesaTransaction < ApplicationRecord
  scope :pending, -> { where(status: "PENDING") }
  scope :completed, -> { where(status: "COMPLETED") }
  scope :failed, -> { where(status: "FAILED") }
  belongs_to :order, optional: true

  validates :checkout_request_id, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :phone_number, presence: true

  def pending?
    status == "PENDING"
  end

  def completed?
    status == "COMPLETED"
  end

  def failed?
    status == "FAILED"
  end

  def complete!
    update(status: "COMPLETED")
    order&.mark_as_paid!
  end

  def fail!(result_code = nil, result_desc = nil)
    update(
      status: "FAILED",
      result_code: result_code,
      result_desc: result_desc
    )
  end
end
