class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.string :title, limit: 150

      t.timestamps
    end
  end
end
