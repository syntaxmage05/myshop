class Product < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  MAX_PRODUCT_NAME_LENGTH = 200

  validates :name, length: { maximum: MAX_PRODUCT_NAME_LENGTH }
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  belongs_to :category
  has_one_attached :image

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
end
