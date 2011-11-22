class BoardsController < ApplicationController

  def create 
    name = params[:board][:name]
    status = :ok 

    @board = name.empty? ? nil : Board.new(:name => name)
    unless @board.nil? 
      courses = params[:courses] 
      courses.each { |id, attributes| 
        @board.courses.build attributes 
      } 
    end 
    status = (@board && @board.save) ? :ok : :bad_request 
    head status 
  end 

  def update 
    head :ok
  end 

end
