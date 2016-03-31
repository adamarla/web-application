class CreateLevels < ActiveRecord::Migration
  def up
    create_table :levels do |t|
      t.string :name, limit: 30      
    end

    Level.create name: 'middle'
    Level.create name: 'secondary'
    Level.create name: 'senior'
  end

  def down
    drop_table :levels
  end 
end
