# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

################################################################################

adam = Examiner.new :first_name => "Abhinav", :last_name => "Chaturvedi", :is_admin => true
adams_account = adam.build_account :email => 'achaturvedi@gmail.com', 
                                   :username => adam.generate_username, 
                                   :password => 'shibb0leth', 
                                   :password_confirmation => 'shibb0leth'
adam.save 

################################################################################

SUBJECTS = [:maths, :physics, :chemistry, :computer_science, :biology]

SUBJECTS.each { |subject| 
  x = Subject.new 
  x.update_attribute :name, subject.to_s.humanize
} 

YARDSTICKS = {
                  1 => {
                        :description => %{ Student either skipped 
                        the question entirely or made only the briefest
                        of attempts at it
                        },
                        :default_allotment => 0
                  },

                  2 => {
                        :description => %{ Student understood the question
                        and what was required. Seemingly had a line of attack
                        but was still far from formulating the required critical
                        insights needed to solve the problem
                        },
                        :default_allotment => 30
                  }, 

                  3 => { 
                         :description => %{ Some of the required insights
                         were correctly forumulated while others were either
                         missing or wrongly formulated. In all probability, 
                         the student already knows what is missing in his/her 
                         solution
                         },
                         :default_allotment => 60
                  }, 

                  4 => { 
                         :description => %{ Student has captured all the
                         required insights in his/her response but has only 
                         faltered at formulating some of the equations/
                         expressions that need to calculated to arrive at the
                         answer
                         },
                         :default_allotment => 75
                  }, 

                  5 => { 
                         :description => %{ Everything's perfect otherwise 
                         }, 
                         :default_allotment => 90
                  },

                  6 => { 
                         :description => %{ All required insights captured,
                         all calculations done correctly, instructions for the
                         question followed precisely
                         }, 
                         :default_allotment => 100
                  }, 

                  7 => { 
                         :description => %{ The solution cannot be faulted.
                         However, the student has not strictly adhered to 
                         instructions specified for the question
                         }, 
                         :default_allotment => 100
                  }, 

                  8 => { 
                         :description => %{ Carried over the wrong values
                         from previous parts as inputs to this part, and 
                         hence getting the wrong answer. The method is
                         otherwise perfect
                         },
                         :default_allotment => 85
                  }, 

                  9 => { 
                         :description => %{ No options selected for this 
                         multiple choice question (MCQ) }, 
                         :default_allotment => 0
                  },

                  10 => { 
                         :description => %{ All correct choices, and none
                         of the wrong ones, selected for this multiple choice
                         question (MCQ) }, 
                         :default_allotment => 100
                  }, 

                  11 => { 
                          :description => %{ Not all correct choices 
                          selected. However, none of the wrong options were
                          marked either},
                          :default_allotment => 60
                  }, 

                  12 => { 
                          :description => %{ Some of the selected choices
                          are wrong. However, the others are correct},
                          :default_allotment => 40
                  }, 

                  13 => { 
                          :description => %{ None of the selected options
                          are correct}, 
                          :default_allotment => 0
                  }
}


YARDSTICKS.each { |k, yardstick|
  b = yardstick[:description].strip.split.join(' ')
  c = yardstick[:default_allotment]

  x = Yardstick.new 
  x.update_attributes :description => b, :default_allotment => c
}
