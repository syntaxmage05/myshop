class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.decimal :price, precision: 6, scale: 2
      t.boolean :available
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
