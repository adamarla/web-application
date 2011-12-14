
object @school 

attributes :name, :street_address, :city, :state, :phone, :zip_code
code :active do |m| 
  m.account.active
end 
