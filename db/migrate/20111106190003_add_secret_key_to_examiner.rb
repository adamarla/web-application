class AddSecretKeyToExaminer < ActiveRecord::Migration
  def change
    add_column :examiners, :secret_key, :string
  end
end
