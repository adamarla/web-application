
class AnnotateScan < Struct.new(:scan, :coordinates)
  def perform
    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['annotate_scan']}" 
    response = SavonClient.request :wsdl, :annotate_scan do
      soap.body = {
        :scanId => scan, 
        :coordinates => coordinates
      }
    end # of response
  end

end # of class
