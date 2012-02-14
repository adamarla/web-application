
# Returned json : { :preview => { :id => 5, :indices => [0,1,2,3,4] } } where
# 'indices' represents the list of page numbers in the quiz
# 
# Given the list always starts with 0, we could have sent just the 
# total # of pages back to whoever it is that needs it. But the form 
# of the returned json is one that we intend to use for all previews 
# - even in cases where the list of indices is not a contiguous set of numbers

object false => :preview 
  code :indices do
    @yardsticks.map { |x| x.id }
  end 

  code :id do
    :preview
  end
