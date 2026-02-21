class Category < ApplicationRecord
  MAX_CATEGORY_NAME_LENGTH = 200

  validates :name, length: { maximum: MAX_CATEGORY_NAME_LENGTH }
  has_many :products

  def self.ransackable_associations(auth_object = nil)
    [ "products" ]
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "id", "name", "updated_at" ]
  end
end
