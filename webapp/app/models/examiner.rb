# == Schema Information
#
# Table name: examiners
#
#  id            :integer         not null, primary key
#  num_contested :integer         default(0)
#  created_at    :datetime
#  updated_at    :datetime
#

class Examiner < ActiveRecord::Base
  has_one :account, :as => :loggable
  has_many :db_questions 

  def provision_db_slot(attributes = {:subject => nil, :grade => nil, :flags => 0})
    root = "#{ENV['VTA_ROOT']}/" 
    # Puts checks either in the controller or in the javascript to ensure 
    # that :subject and :grade are non-nil by the time they get here. Ideally
    # :flags should also != 0. But :flags == 0 is something we can live with 
    # till such time it is set
    # Call : obj.provision_db_slot :subject => :maths, :grade => 9, :flags => 0022

    subject = attributes[:subject] 
    grade = attributes[:grade]

    # 'rel_path' represents the path relative to VTA_ROOT where TeX for the new 
    # question *will be* stored. However, the path is not fully known at the time of 
    # creation. For one, we don't know what the last index in the DB is. Hence,
    # we first block a slot and then store with a final value for 'rel_path'
    rel_path = "#{subject.to_s}/G#{grade}"
    new_dbq = self.db_questions.build(:path => rel_path, :flags => attributes[:flags])
    new_dbq.save # there, a slot is now blocked in the DB

    rel_path += "/#{new_dbq.id}"  
    full_path = root + rel_path
    new_dbq.update_attribute(:path,rel_path) # 2nd pass

    # Now issue a series of system commands
    system("mkdir -p #{full_path} && cp #{root}/common/Makefile #{full_path}")
    system("cd #{root} && git add #{rel_path}")

  end 

end
