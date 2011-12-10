class TrimYardsticks < ActiveRecord::Migration
  def up
    change_table :yardsticks do |t| 
      t.remove :annotation
      t.remove :active 
      t.remove :subpart
    end 
  end

  def down
    change_table :yardsticks do |t| 
      t.string :annotation 
      t.boolean :active, :default => true 
      t.boolean :subpart, :default => false
    end 
  end

end
