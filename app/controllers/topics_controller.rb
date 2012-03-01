class TopicsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def create 
    options = params[:topic] 
		@topic = Topic.new :name => options[:name], :vertical_id => options[:vertical]
		@topic.save ? respond_with(@topic) : head(:bad_request)
  end 

  def update 
    head :ok
  end 

  def list 
    @categories = Vertical.order(:name).all 
    respond_with @categories 
  end 

end
