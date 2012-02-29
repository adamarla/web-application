class TopicsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def create 
    options = params[:topic] 
    category_name = options.delete :new_category

    if category_name.blank? 
      @topic = Topic.new :name => options[:name], :vertical_id => options[:category]
    else 
      category = Vertical.where(:name => category_name).first || Vertical.new(:name => category_name) 
      category.save if category.new_record? 

      @topic = category.topics.new :name => options[:name]
    end 
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
