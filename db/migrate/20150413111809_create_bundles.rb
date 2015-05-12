class CreateBundles < ActiveRecord::Migration
  def change
    create_table :bundles do |t|
      t.string :uid, limit: 50

      t.timestamps
    end

  end
end
