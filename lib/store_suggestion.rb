class StoreSuggestion < Struct.new(:teacher_id, :signature, :payload)

  def perform

    puts "########################################"
    puts teacher_id
    puts signature
    puts "########################################"

    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['upload_suggestion']}"

    response = SavonClient.request :wsdl, :uploadSuggestion do
      soap.body = {
        :teacher => { :id => teacher_id },
        :signature => signature ,
        :content => payload
      }
    end 
    manifest = response[:upload_suggestion_response][:manifest]
    unless manifest.nil?
      suggestion = Suggestion.new(:teacher_id => teacher_id , :signature => signature )
      suggestion.save
    end
  end

end
