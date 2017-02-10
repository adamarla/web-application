class RenameSnippetToFragment < ActiveRecord::Migration
  def up
    rename_table :snippets, :fragments 

    ActsAsTaggableOn::Tagging.where(taggable_type: "Snippet").each do |tg| 
      tg.update_attribute :taggable_type, "Fragment" 
    end 

    Sku.where(stockable_type: "Snippet").each do |s|
      s.update_attribute :stockable_type, "Fragment"
    end 
  end 

  def down 
    rename_table :fragments, :snippets 

    ActsAsTaggableOn::Tagging.where(taggable_type: "Fragment").each do |tg| 
      tg.update_attribute :taggable_type, "Snippet" 
    end 

    Sku.where(stockable_type: "Fragment").each do |s|
      s.update_attribute :stockable_type, "Snippet"
    end 
  end 
end
