class TopicsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def create 
    vertical = params[:vertical]
    added = true 

    params[:names].each_value do |v|
      next if v.blank?
      topic = Topic.new :name => v, :vertical_id => vertical
      added &= topic.save
      break if !added
    end
    added ? render(:json => {:status => 'Done'}, :status => :ok) : 
            render(:json => {:status => 'Oops!'}, :status => :bad_request)
  end 

  def update 
    head :ok
  end 

  def list 
    @categories = Vertical.order(:name).all 
    respond_with @categories 
  end 

end
