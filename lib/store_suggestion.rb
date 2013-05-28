class StoreSuggestion < Struct.new(:teacher_id, :signature, :payload)

  def perform
    teacher = Teacher.find teacher_id 
    suggestion = teacher.suggestions.build 

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

      unless manifest.nil?
        unless manifest[:root].blank?
          suggestion[:signature] = manifest[:root].split('/').last
          suggestion[:pages] = manifest[:image].count
          # assign to an examiner
          e = Examiner.where(:is_admin => true).sort{ |m,n| m.suggestion_ids.count <=> n.suggestion_ids.count }.first
          suggestion[:examiner_id] = e.id
          suggestion.save
        end
      end
    end
  end # of perform 
end
