
# Dynamic attr_accessible support (Railscasts #237)

# The problem with a simple attr_accessible is that either everyone
# can mass assign the attribute (through forms, curl commands etc) 
# or no one can ( if attribute is not listed as attr_accessible). There
# was no middle ground - until Rails 3

# Now, we can conditionally make attributes accessible based on 
# who it is who is trying to do the assignment and in what context

# In the models - as before - call attr_accessible with attributes
# that can be assigned by anyone. 

# In the controllers, however, conditionally add attributes that can
# also be mass-assigned BEFORE doing the assignments ( using 
# update_attributes and the like )

#class ActiveRecord::Base 
#  attr_accessible 
#  attr_accessor :accessible
#
#  private 
#    def mass_assignment_authorizer
#      if accessible == :all 
#        self.class.protected_attributes
#      else 
#        super + (accessible || [])
#      end 
#    end 
#  
#end 
