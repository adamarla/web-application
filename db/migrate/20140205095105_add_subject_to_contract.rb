class AddSubjectToContract < ActiveRecord::Migration
  def change
    add_column :contracts, :subject_id, :integer
  end
end
