class CreateAssets < ActiveRecord::Migration[7.1]
  def change
    create_table :assets do |t|
      t.string :code
      t.string :name
      t.boolean :fiat

      t.timestamps
    end
  end
end
