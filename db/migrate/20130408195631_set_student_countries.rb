class SetStudentCountries < ActiveRecord::Migration
  def up
    Account.where{(loggable_type == 'Teacher') & (country != nil) & (country != 100)}.each do |m|
      m.loggable.students.each do |n|
        n.account.update_attribute :country, m.country
      end 
    end # non-Indian teachers
  end

  def down
  end
end
