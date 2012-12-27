class CreateRequirements < ActiveRecord::Migration
  def change
    create_table :requirements do |t|
      t.string :text
      t.boolean :honest, :default => false
      t.boolean :cogent, :default => false
      t.boolean :complete, :default => false
      t.boolean :other, :default => false
      t.integer :weight, :default => -1
    end
  end
end
