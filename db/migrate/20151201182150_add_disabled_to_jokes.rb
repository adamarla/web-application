class AddDisabledToJokes < ActiveRecord::Migration
  def change
    add_column :jokes, :disabled,:boolean, default: false
  end
end
