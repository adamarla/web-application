class PuzzlesController < ApplicationController
  before_filter :authenticate_account!, except: [ :next ] 
  respond_to :json

  def create 
    p = params[:puzzle]
    pzl = Puzzle.new question_id: p[:id], text: p[:text]
    if pzl.save
      render json: { id: pzl.id }, status: :ok
    else
      render json: { status: :error }, status: :ok
    end 
  end 

  def load 
    id = params[:id].blank? ? nil : params[:id].to_i
    @p = id.nil? ? Puzzle.where(active: true).first : Puzzle.find(id)
  end 

  def next
    Puzzle.next 
    render json: { status: :done }, status: :ok
  end 

end
