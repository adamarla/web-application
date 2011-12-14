
object @course
  attributes :name
  child @syllabi do 
    extends 'syllabi/show'
  end 
