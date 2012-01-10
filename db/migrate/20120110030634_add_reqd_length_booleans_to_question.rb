class AddReqdLengthBooleansToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :half_page, :boolean, :default => false
    add_column :questions, :full_page, :boolean, :default => true
  end
end
