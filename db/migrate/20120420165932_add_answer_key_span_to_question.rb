class AddAnswerKeySpanToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :answer_key_span, :integer
  end
end
