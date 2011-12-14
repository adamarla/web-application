class AddActiveBooleanToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :active, :boolean, :default => true
	Course.reset_column_information
	Course.all.each { |course| course.update_attribute(:active, true) }
  end
end
