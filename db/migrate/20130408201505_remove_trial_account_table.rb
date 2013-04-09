class RemoveTrialAccountTable < ActiveRecord::Migration
  def up
    drop_table :trial_accounts
  end

  def down
    create_table :trial_accounts do |t|
      t.integer :teacher_id
      t.string :school
      t.string :zip_code
      t.integer :country
      t.timestamps
    end
  end
end
