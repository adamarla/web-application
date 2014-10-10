class CreateRevisions < ActiveRecord::Migration
  def change
    create_table :revisions do |t|
      t.integer :question_id 
      t.boolean :latex, default: false 
      t.boolean :hints, default: false
    end
  end
end
