class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :amount, null: false, precision: 30, scale: 18
      # TODO: Do some math and see if we should go with a greater precision/scale for amount_remaining:
      # TODO: To clarify why: I think it might be possible for an order to be filled in a way that we need more precision to calculate how much remains
      t.decimal :amount_remaining, null: false, precision: 30, scale: 18
      t.integer :order_type, null: false
      t.integer :status, null: false, default: 0
      t.decimal :price, precision: 30, scale: 18
      t.integer :direction, null: false
      t.boolean :locked, null: false, default: true

      t.timestamps
    end
  end
end
