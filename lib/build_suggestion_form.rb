
class BuildSuggestionForm < Struct.new(:teacher)
  
  def perform 
    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['generate_suggestion_form']}" 
    response = SavonClient.request :wsdl, :generate_suggestion_form do  
      soap.body = {
         :teacher => {:id => teacher.id, :name => "#{teacher.first_name}-#{teacher.last_name}"},
         :school => {:id => teacher.school.id, :name => teacher.school.name }
      }
    end # of response 
  end 

end 
