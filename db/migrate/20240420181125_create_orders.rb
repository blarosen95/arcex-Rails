class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :currency, null: false
      t.decimal :amount, null: false, precision: 30, scale: 18
      t.integer :order_type, null: false
      t.integer :status, null: false, default: 0
      t.decimal :price, precision: 30, scale: 18
      t.integer :direction, null: false

      t.timestamps
    end
  end
end
