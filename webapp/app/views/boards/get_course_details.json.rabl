object @board

child :courses do 
  attributes :name, :grade, :active

  child :subject do 
    attribute :name 
  end 
end 
