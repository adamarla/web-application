class RemoveUidFromStudents < ActiveRecord::Migration
  def up
    remove_column :students, :uid
  end

  def down
    add_column :students, :uid, :string, limit: 20
  end
end
