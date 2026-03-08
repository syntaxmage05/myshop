# frozen_string_literal: true

class Category < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged
  MAX_CATEGORY_NAME_LENGTH = 200

  has_many :products, dependent: :destroy, counter_cache: true
  validates :name, length: { maximum: MAX_CATEGORY_NAME_LENGTH }

  def self.ransackable_associations(auth_object = nil)
    [ "products" ]
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "id", "name", "updated_at", "slug" ]
  end
end
