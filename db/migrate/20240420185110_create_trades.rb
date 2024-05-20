class CreateTrades < ActiveRecord::Migration[7.1]
  def change
    # TODO: We should have reference to the Asset models. One called `fiat_asset` (buying instrument) and one called `crypto_asset` (sold instrument):
    create_table :trades do |t|
      t.references :immediate_order, null: false, foreign_key: { to_table: :orders }
      t.references :book_order, null: false, foreign_key: { to_table: :orders }
      t.integer :status, null: false, default: 0
      t.decimal :execution_price, precision: 30, scale: 18
      t.decimal :execution_amount, precision: 30, scale: 18
      t.decimal :immediate_order_fee, precision: 30, scale: 18
      t.decimal :book_order_fee, precision: 30, scale: 18

      t.timestamps
    end
  end
end
