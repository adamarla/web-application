# == Schema Information
#
# Table name: drafts
#
#  id      :integer         not null, primary key
#  layout  :string(255)
#  quiz_id :integer
#  index   :integer
#

class Draft < ActiveRecord::Base
  belongs_to :quiz
  after_create :set_index

  def set_index
    last = Draft.where(quiz_id: self.quiz_id).order(:index).last
    lidx = last.nil? ? -1 : last.index
    self.update_attribute :index, (lidx + 1)
  end

end
