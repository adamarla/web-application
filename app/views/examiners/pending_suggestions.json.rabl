
collection @suggestions => :suggestions 
  attributes :id, :filesignature
  glue :teacher do
    attributes :print_name => :name
  end
  