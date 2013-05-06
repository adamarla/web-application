
object @school 

attributes :name, :phone, :board_id
node :active do |m| 
  m.account.active
end 
