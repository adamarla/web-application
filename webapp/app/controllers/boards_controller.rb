class BoardsController < ApplicationController
  respond_to :json 

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

  def summary 
    @boards = Board.all 
    respond_with @boards 
  end 

=begin
  def get_course_details
    @board = Board.find params[:board_id]

    unless @board.nil? 
      respond_with @board
    else
      head :bad_request
    end 
  end 
=end

end
