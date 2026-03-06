# frozen_string_literal: true

class CreateMpesaTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :mpesa_transactions do |t|
      t.references :order, null: false, foreign_key: true
      t.string :checkout_request_id
      t.string :merchant_request_id
      t.decimal :amount
      t.string :status
      t.string :phone_number
      t.string :result_code
      t.string :result_desc

      t.timestamps
    end
  end
end
