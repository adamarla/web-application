class RemoveCountryIdFromTeachers < ActiveRecord::Migration
  def up
    # First, transfer existing country info to corresponding account
    Teacher.all.each do |m|
      m.account.update_attribute(:country, m.country_id) unless m.account.nil?
    end 
    # Then, remove the column
    remove_column :teachers, :country_id
  end

  def down
    add_column :teachers, :country_id, :integer
    Teacher.all.each do |m|
      m.update_attribute(:country_id, m.account.country) unless m.account.nil?
    end 
  end
end
