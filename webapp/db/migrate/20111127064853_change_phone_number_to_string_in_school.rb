class ChangePhoneNumberToStringInSchool < ActiveRecord::Migration
  def up
    change_column :schools, :phone, :string
  end

  def down
    change_column :schools, :phone, :integer
  end
end
