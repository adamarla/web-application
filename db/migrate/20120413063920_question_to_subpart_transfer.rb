class QuestionToSubpartTransfer < ActiveRecord::Migration
  def up
    Question.all.each do |q|
      q.split_into_subparts
    end
  end

  def down
    Question.all.each do |q|
      q.rebuild_from_subparts
    end
  end
end
