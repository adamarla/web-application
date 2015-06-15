class AddSignatureToBundle < ActiveRecord::Migration
  def change
    add_column :bundles, :signature, :string, limit: 20
  end
end
