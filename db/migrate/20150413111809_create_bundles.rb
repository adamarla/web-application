class CreateBundles < ActiveRecord::Migration
  def change
    create_table :bundles do |t|
      t.string :title, limit: 150
      t.integer :package_id
      t.string :uid, limit: 50

      t.timestamps
    end

  end
end
