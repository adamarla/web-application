class AddUidToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :uid, :string, :limit => 10
    School.all.each do |s|
      s.assign_uid
    end
  end
end
