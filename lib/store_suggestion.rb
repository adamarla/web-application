class StoreSuggestion < Struct.new(:teacher_id, :signature, :payload)

  def perform
    teacher = Teacher.find teacher_id 
    suggestion = teacher.suggestions.build :signature => signature

    if suggestion.valid?
      SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['upload_suggestion']}"

      response = SavonClient.request :wsdl, :uploadSuggestion do
        soap.body = {
          :teacher => { :id => teacher_id },
          :signature => signature ,
          :content => payload
        }
      end 
      manifest = response[:upload_suggestion_response][:manifest]
      suggestion.save unless manifest.nil?
    end
  end # of perform 
end
