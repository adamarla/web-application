class TrackKaagazInRemarks < ActiveRecord::Migration
  def change 
    rename_column :remarks, :stab_id, :kaagaz_id
  end 
end
