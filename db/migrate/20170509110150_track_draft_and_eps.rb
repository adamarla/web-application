class TrackDraftAndEps < ActiveRecord::Migration
  def up
    remove_column :riddles, :has_draft 
    remove_column :skills, :has_draft 
    add_column :skus, :has_draft, :boolean, default: false 
    add_column :skus, :num_eps, :integer, default: 0 
  end

  def down
    change_table :skus do |t| 
      t.remove :has_draft 
      t.remove :num_eps 
    end 
    add_column :skills, :has_draft, :boolean, default: false 
    add_column :riddles, :has_draft, :boolean, default: false 
  end
end
