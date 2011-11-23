object @board

child :courses do 
  attributes :name, :grade, :active, :id

  child :subject do 
    attribute :name 
  end 
end 
