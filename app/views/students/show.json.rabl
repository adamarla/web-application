
# @who_wants_to_know = current_account.role for the currently logged in user
# If its :admin, :teacher or :school, then we show the student's generated 
# login along with the name. Otherwise not

object @student 
  attributes :id 
  code :name do |m| 
    m.name @who_wants_to_know
  end 
