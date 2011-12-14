class CreateParents < ActiveRecord::Migration
  def change
    create_table :parents do |t|
      t.boolean :is_mother

      t.timestamps
    end
  end
end
