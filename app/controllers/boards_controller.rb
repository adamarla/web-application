class BoardsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json 

  def create
    boards = params[:board]

    boards.keys.each do |k|
      name = boards[k]
      unless name.empty?
        m = Board.new :name => name
        m.save
      end
    end
    render :json => { :status => "done" }, :status => :ok
  end

  def update 
    head :ok
  end 

  def summary 
    @boards = Board.all 
    respond_with @boards 
  end 

end # of controller
