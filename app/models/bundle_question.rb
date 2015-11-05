# == Schema Information
#
# Table name: bundle_questions
#
#  id          :integer         not null, primary key
#  bundle_id   :integer
#  question_id :integer
#  label       :string(8)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class BundleQuestion < ActiveRecord::Base
  # attr_accessible :bundle_id, :question_id
  belongs_to :bundle
  belongs_to :question

  def name 
    bundle_uid = self.bundle.uid 
    return "" unless bundle_uid.starts_with?("cbse")
    year = bundle_uid.split('-')[3] 
    return "CBSE #{year} Q.#{self.label}"
  end 

end
