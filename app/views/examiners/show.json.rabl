
object @examiner 
  attributes :id 

  code :name do |m|
    m.name
  end 

  glue :account do 
    attributes :username 
  end 
