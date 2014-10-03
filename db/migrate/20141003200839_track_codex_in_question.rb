class TrackCodexInQuestion < ActiveRecord::Migration
  def change 
    add_column :questions, :n_codices, :integer, default: 0
    add_column :questions, :codices, :string, limit: 5
  end 
end
