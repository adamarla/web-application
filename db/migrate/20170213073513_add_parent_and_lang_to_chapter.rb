class AddParentAndLangToChapter < ActiveRecord::Migration
  def change
    add_column :chapters, :language_id, :integer, default: Language.named('english')
    add_column :chapters, :parent_id, :integer, default: 0
  end
end
