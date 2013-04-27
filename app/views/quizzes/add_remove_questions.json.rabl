
object false 
  node(:notify) { 
    { :title => @title, :msg => @msg }
  } 

  node(:monitor, :if => lambda { |m| !@clone.nil? }) {
    { :quiz => @clone.id }
  } 
