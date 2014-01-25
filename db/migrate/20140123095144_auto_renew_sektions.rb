class AutoRenewSektions < ActiveRecord::Migration
  def up 
    change_table :sektions do |t|
      t.date :start_date 
      t.date :end_date
      t.boolean :auto_renew, default: true
      t.boolean :active
    end
  end 

  def down
    change_table :sektions do |t|
      t.remove :active
      t.remove :auto_renew
      t.remove :end_date
      t.remove :start_date 
    end
  end 
end
