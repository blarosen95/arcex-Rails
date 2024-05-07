class AddAssetsReferenceToContents < ActiveRecord::Migration[7.1]
  def change
    add_reference :contents, :asset, null: false, index: true, foreign_key: true
  end
end
