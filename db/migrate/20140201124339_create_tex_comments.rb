class CreateTexComments < ActiveRecord::Migration
  def change
    create_table :tex_comments do |t|
      t.text :text
      t.integer :examiner_id # the original author of the comment
      t.boolean :trivial
      t.timestamps
    end
  end
end
