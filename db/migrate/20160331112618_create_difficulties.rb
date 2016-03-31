class CreateDifficulties < ActiveRecord::Migration
  def up
    create_table :difficulties do |t|
      t.string :name, limit: 50
      t.integer :level
    end

    Difficulty.create(name: 'Easy (Most can do)', level: 10)
    Difficulty.create(name: 'Medium (Some can do)', level: 20) 
    Difficulty.create(name: 'Hard (Competition Level)', level: 30)
    Difficulty.create(name: 'Insane (Olympiad Level)', level: 40)
  end

  def down 
    drop_table :difficulties
  end 
end
