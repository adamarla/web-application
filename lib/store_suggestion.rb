class StoreSuggestion < Struct.new(:teacher_id, :signature, :payload)

  def perform

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
      suggestion = Suggestion.new(:teacher_id => teacher_id , :signature => signature , :pages => manifest[:image].count)
      suggestion.save
    end
  end

end
