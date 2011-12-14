class AddTagToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :tag, :string
  end
end
