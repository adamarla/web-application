class CreateTexComments < ActiveRecord::Migration
  def change
    create_table :tex_comments do |t|
      t.text :text
      t.integer :n_used_self, default: 0
      t.integer :n_used_others, default: 0
      t.integer :examiner_id # the original author of the comment
      t.timestamps
    end
  end
end
