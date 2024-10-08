class CreateWallets < ActiveRecord::Migration[7.1]
  def change
    create_table :wallets do |t|
      ## Relationships
      t.references :user, null: false, foreign_key: true

      ## Attributes/Columns
      t.string :name

      ## Timestamps
      t.timestamps
    end
  end
end
