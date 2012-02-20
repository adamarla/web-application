class RemoveSecretKeyFromExaminers < ActiveRecord::Migration
  def up
    remove_column :examiners, :secret_key
  end

  def down
    add_column :examiners, :secret_key, :string
  end
end
