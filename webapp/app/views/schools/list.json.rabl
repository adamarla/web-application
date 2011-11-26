
# Output Example : 
#  {"schools":[{"school":{"name":"AFBBS","zip_code":"110003","phone":null,"id":1,"address":"Lodi Road, New Delhi"}}]}

collection @schools => :schools

attributes :name, :zip_code, :phone, :id
code :address do |m|
  m.street_address + ", " + m.city
end 
