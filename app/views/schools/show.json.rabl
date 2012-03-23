
object @school 

attributes :name, :street_address, :city, :state, :phone, :zip_code, :board_id
node :active do |m| 
  m.account.active
end 
