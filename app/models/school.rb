# == Schema Information
#
# Table name: schools
#
#  id             :integer         not null, primary key
#  name           :string(255)
#  street_address :string(255)
#  city           :string(255)
#  state          :string(255)
#  zip_code       :string(255)
#  phone          :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  tag            :string(255)
#  board_id       :integer
#

class School < ActiveRecord::Base
  has_one :account, :as => :loggable
  has_many :students
  has_many :teachers
  has_many :sektions

  validates :name, :presence =>true
  validates :tag, :presence => true
  validates :zip_code, :presence => true
  validates :board_id, :presence => true

  scope :state_matches, lambda { |criterion| (criterion.nil? || criterion[:state].blank?) ? 
                              where('state IS NOT NULL') : where(:state => criterion[:state]) } 

  # Should we allow deletion of schools from the DB ? My view is, don't. 
  # Don't because whatever information you may have accumulated about the 
  # school and its students' performance is valuable. At most, disable the account.
  # Also, instead of trying to prevent deletion through controller and view,
  # - which can be hacked - de-fang the operation in the model itself. 

  before_destroy :destroyable? 

  def create_sektions(klasses, sections) 
    # 'klasses' and 'sections' are arrays 

    klasses.each { |klass|
      sections.each { |section| 
        grp = self.sektions.new :klass => klass, :section => section 
        grp.save 
        # 'save' can fail because of uniqueness validation. That's ok
      }
    }
    return true 
  end # of method  

  private 
    def destroyable? 
      return false
    end 
end
