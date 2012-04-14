class AddSubpartFkToGradedResponse < ActiveRecord::Migration
  def up
    change_table :graded_responses do |t|
      t.integer :subpart_id
    end

    # At the time of writing, there were only stand-alone questions
    # - meaning, questions with only 1 subpart (themselves). And 
    # the subparts table has been populated before this migration 
    Question.select{ |m| m.num_parts? == 0 }.each do |q|
      s = q.subparts.first
      GradedResponse.to_question(q.id).each do |r|
        r.update_attribute :subpart_id, s.id
      end
    end
  end

  def down 
    remove_column :graded_responses, :subpart_id
  end 

end
