
object @school 
  attributes :id, :name 

  code :username do |m|
    m.account.username
  end 
