class CreateDifficulties < ActiveRecord::Migration
  def up
    create_table :difficulties do |t|
      t.string :name, limit: 10
      t.string :meaning, limit: 40
      t.integer :level
    end

    Difficulty.create(name: 'easy', meaning: 'Most can do', level: 10)
    Difficulty.create(name: 'medium', meaning: 'Some can do', level: 20)
    Difficulty.create(name: 'hard', meaning: 'Competition Level', level: 30)
    Difficulty.create(name: 'insane', meaning: 'Olympiad Level', level: 40)
  end

  def down 
    drop_table :difficulties
  end 
end
