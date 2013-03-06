class TrimStudent < ActiveRecord::Migration
  def up
    remove_column :students, :school_id
    remove_column :students, :klass
  end

  def down
    add_column :students, :school_id, :integer
    add_column :students, :klass, :integer
  end
end
