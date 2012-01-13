
object @school 

attributes :name, :street_address, :city, :state, :phone, :zip_code, :board_id
code :active do |m| 
  m.account.active
end 
