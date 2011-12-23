class MicroTopicsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def create 
    options = params[:topic] 
    category_name = options.delete :new_category

    if category_name.blank? 
      @topic = MicroTopic.new :name => options[:name], :macro_topic_id => options[:category]
    else 
      category = MacroTopic.where(:name => category_name).first || MacroTopic.new(:name => category_name) 
      category.save if category.new_record? 

      @topic = category.micro_topics.new :name => options[:name]
    end 
    @topic.save ? respond_with(@topic) : head(:bad_request) 
  end 

  def update 
    head :ok
  end 

  def list 
    @categories = MacroTopic.order(:name).all 
    respond_with @categories 
  end 

end
