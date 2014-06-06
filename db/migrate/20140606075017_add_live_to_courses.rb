class AddLiveToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :live, :boolean, default: true
  end
end
