class AddPackageToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :package_id, :integer
  end
end
