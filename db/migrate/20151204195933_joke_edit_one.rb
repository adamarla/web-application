class JokeEditOne < ActiveRecord::Migration
  def up
    remove_column :jokes, :image 
    add_column :jokes, :category, :string, limit: 20
  end

  def down
    add_column :jokes, :image, :boolean, default: true 
    remove_column :jokes, :category 
  end
end
