# frozen_string_literal: true

class AddProductCountToCategory < ActiveRecord::Migration[8.0]
  def change
    add_column :categories, :products_count, :integer
  end
end
