
class RotateScan < Struct.new(:scan_locker_path)
  def perform
    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['rotate_scan']}" 
    response = SavonClient.request :wsdl, :rotateScan do  
      soap.body = {
        :scanId => scan_locker_path
      }
    end
  end
end
