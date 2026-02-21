class Product < ApplicationRecord
  MAX_PRODUCT_NAME_LENGTH = 200

  validates :name, length: { maximum: MAX_PRODUCT_NAME_LENGTH }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  belongs_to :category

  def self.ransackable_associations(auth_object = nil)
    [ "category" ]
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "available", "category_id", "created_at", "description", "id", "name", "price", "updated_at" ]
  end
end
