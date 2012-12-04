
class RestorePristineScan < Struct.new(:scan_locker_path)
  def perform
    # Reset the graded responses corresponding this scan 
    scan = scan_locker_path.split('/').last
    scan = scan.length == 2 ? scan.last : nil 
    unless scan.blank?
      GradedResponse.where(:scan => scan).each do |m| 
        m.reset
      end 
    end
    # Then, issue request for restoring the pristine copy of the scan 
    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['undo_annotate']}" 
    response = SavonClient.request :wsdl, :undoAnnotate do  
      soap.body = {
        :scanId => scan_locker_path
      }
    end
  end
end
