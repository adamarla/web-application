class RenameQuestionToProblem < ActiveRecord::Migration
  def up
    rename_table :questions, :problems 

    ActsAsTaggableOn::Tagging.where(taggable_type: "Question").each do |tg| 
      tg.update_attribute :taggable_type, "Problem" 
    end 

    Sku.where(stockable_type: "Question").each do |s|
      s.update_attribute :stockable_type, "Problem"
    end 
  end 

  def down 
    rename_table :problems, :questions 

    ActsAsTaggableOn::Tagging.where(taggable_type: "Problem").each do |tg| 
      tg.update_attribute :taggable_type, "Question" 
    end 

    Sku.where(stockable_type: "Problem").each do |s|
      s.update_attribute :stockable_type, "Question"
    end 
  end 
end
