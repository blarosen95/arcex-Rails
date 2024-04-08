class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.references :sender, null: false, foreign_key: { to_table: :wallets }
      t.references :recipient, null: false, foreign_key: { to_table: :wallets }
      t.string :currency
      t.decimal :amount, precision: 10, scale: 2

      t.timestamps

      ## Indexes
      t.index [:sender_id, :recipient_id]
    end

    #! TODO: Add this same logic as a model-level validation:
    # Ensure sender_id and recipient_id are not the same
    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          ALTER TABLE transactions
          ADD CONSTRAINT sender_recipient_different
          CHECK (sender_id != recipient_id)
        SQL
      end
      dir.down do
        execute <<-SQL.squish
          ALTER TABLE transactions
          DROP CONSTRAINT sender_recipient_different
        SQL
      end
    end
  end
end
