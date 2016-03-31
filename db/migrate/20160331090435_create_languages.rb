class CreateLanguages < ActiveRecord::Migration
  def up
    create_table :languages do |t|
      t.string :name, limit: 30      
    end

    Language.create name: 'english'
  end

  def down
    drop_table :languages
  end 
end
