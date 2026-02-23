# frozen_string_literal: true

class Product < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  MAX_PRODUCT_NAME_LENGTH = 200

  belongs_to :category
  has_many :line_items
  validates :name, length: { maximum: MAX_PRODUCT_NAME_LENGTH }
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  has_one_attached :image

  before_destroy :ensure_not_referenced_by_any_line_item

  def self.ransackable_attributes(auth_object = nil)
    %w[
      id
      name
      description
      price
      available
      category_id
      created_at
      updated_at
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[category]
  end

  private

    # Ensure that there are no line items referencing this product
    def ensure_not_referenced_by_any_line_item
      unless line_items.empty?
        errors.add(:base, "Line items present")
        throw :abort
      end
    end
end
