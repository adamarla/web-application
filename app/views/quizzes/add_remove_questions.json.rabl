
object false 
  node(:notify) { 
    { title: @title, msg: @msg }
  } 

  node(:monitor, if: lambda { |m| !@last_child.nil? }) {
    { quiz: [@last_child.id] }
  } 
