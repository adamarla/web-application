class ChangeAtmKeyToStringOverwrite < ActiveRecord::Migration
  def up
    change_column :quizzes, :atm_key, :string
  end

  def down
    change_column :quizzes, :atm_key, :integer
  end
end
