class CreateFavourites < ActiveRecord::Migration
  def change
    create_table :favourites do |t|
      t.references :teacher
      t.references :question
    end
  end
end
