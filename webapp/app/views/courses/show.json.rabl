
object @course
  
  attributes :name, :grade, :id 

  child :subject do 
    attributes :name, :id
  end 

  child :specific_topics do 
    attribute :name 
  end 
