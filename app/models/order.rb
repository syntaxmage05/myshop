class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  validates :first_name, :last_name, :email, :address, :post_code, :city, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  # Default ordering
  default_scope { order(created_at: :desc)}

  # lets active admin save the order and items in one form
  accepts_nested_attributes_for :order_items, allow_destroy: true

  def total_cost
    order_items.sum(&:cost)
  end

  def self.ransackable_associations(auth_object = nil)
    ["order_items", "products"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["address", "city", "created_at", "email", "first_name", "id", "last_name", "paid", "post_code", "updated_at"]
  end
end
