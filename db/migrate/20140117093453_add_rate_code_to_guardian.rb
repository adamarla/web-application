class AddRateCodeToGuardian < ActiveRecord::Migration
  def change
    add_column :guardians, :rate_code_id, :integer
  end
end
