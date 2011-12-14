
object @course 
  attributes :name, :id 

  code :board do |m|
    m.board.name
  end 
