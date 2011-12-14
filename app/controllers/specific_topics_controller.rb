class SpecificTopicsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def create 
    options = params[:topic] 
    category_name = options.delete :new_category

    if category_name.blank? 
      @topic = SpecificTopic.new :name => options[:name], :broad_topic_id => options[:category]
    else 
      category = BroadTopic.where(:name => category_name).first || BroadTopic.new(:name => category_name) 
      category.save if category.new_record? 

      @topic = category.specific_topics.new :name => options[:name]
    end 
    @topic.save ? respond_with(@topic) : head(:bad_request) 
  end 

  def update 
    head :ok
  end 

  def list 
    @categories = BroadTopic.order(:name).all 
    respond_with @categories 
  end 

end
