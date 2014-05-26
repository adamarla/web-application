
object false 
  node(:notify) { 
    { title: @title, msg: @msg }
  } 

  node(:monitor, if: lambda { |m| !@last_child.nil? }) {
    { quizzes: [@last_child.id] }
  } 
