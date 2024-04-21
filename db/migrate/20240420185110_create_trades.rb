class CreateTrades < ActiveRecord::Migration[7.1]
  def change
    create_table :trades do |t|
      t.references :order, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.decimal :executed_price, precision: 30, scale: 18
      t.decimal :executed_amount, precision: 30, scale: 18
      t.decimal :fee, precision: 30, scale: 18

      t.timestamps
    end
  end
end
