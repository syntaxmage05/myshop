# frozen_string_literal: true

class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.string :first_name, limit: 50
      t.string :last_name, limit: 50
      t.string :email
      t.string :address, limit: 250
      t.string :post_code, limit: 20
      t.string :city, limit: 100
      t.boolean :paid, default: false

      t.timestamps
    end

    add_index :orders, :created_at
  end
end
