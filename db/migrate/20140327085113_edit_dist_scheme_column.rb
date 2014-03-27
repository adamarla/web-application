class EditDistSchemeColumn < ActiveRecord::Migration
  def up
    change_table :exams do |t|
      t.change :dist_scheme, :text
    end 
  end

  def down
    # No need to reverse migration. 'dist_scheme' is safer being a text
  end
end
