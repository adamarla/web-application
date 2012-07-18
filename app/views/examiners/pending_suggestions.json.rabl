
collection @suggestions => :suggestions 
  attributes :id, :signature
  glue :teacher do
    attributes :print_name => :name
  end
  
