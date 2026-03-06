# frozen_string_literal: true

class Order < ApplicationRecord
  default_scope { order(created_at: :desc) }
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  has_one :mpesa_transaction, dependent: :nullify

  validates :first_name, :last_name, :email, :address, :post_code, :city, :phone, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, format: { with: /\A(0|254)[17]\d{8}\z/, message: "must be a valid Safaricom number" }

  accepts_nested_attributes_for :order_items, allow_destroy: true

  # For ActiveAdmin ransack
  def self.ransackable_associations(auth_object = nil)
    ["order_items", "products", "mpesa_transaction"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["address", "city", "created_at", "email", "first_name", "id", "last_name", "paid", "paid_at", "phone",
"post_code", "updated_at"]
  end

  def total_cost
    order_items.sum { |item| item.price * item.quantity }
  end

  def mark_as_paid!
    update(paid: true, paid_at: Time.current)
  end

  def payment_status
    if paid?
      "Paid"
    elsif mpesa_transaction&.pending?
      "Pending"
    else
      "Unpaid"
    end
  end
end
