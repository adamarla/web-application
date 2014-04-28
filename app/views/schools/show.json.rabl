
object @school 

attributes :name, :phone
node :active do |m| 
  m.account.active
end 
node(:city) { @school.account.city }
