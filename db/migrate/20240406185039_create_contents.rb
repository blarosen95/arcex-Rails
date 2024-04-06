class CreateContents < ActiveRecord::Migration[7.1]
  def change
    create_table :contents do |t|
      t.references :wallet, null: false, foreign_key: true
      t.string :currency
      t.decimal :balance, precision: 10, scale: 2, default: 0.0

      t.timestamps
    end
  end
end
