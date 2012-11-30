
class RestorePristineScan < Struct.new(:scan_locker_path)
  def perform
    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['undo_annotate']}" 
    response = SavonClient.request :wsdl, :undoAnnotate do  
      soap.body = {
        :scanId => scan_locker_path
      }
    end
  end
end
