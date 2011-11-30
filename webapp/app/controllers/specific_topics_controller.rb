class SpecificTopicsController < ApplicationController
  respond_to :json

  def create 
    options = params[:topic] 
    status = :ok 

    unless (options[:category].nil? || options[:category].empty?)
      new_topic = SpecificTopic.new :name => options[:name], :broad_topic_id => options[:category]
    else 
      new_topic = SpecificTopic.new :name => options[:name] 
      new_category = new_topic.build_broad_topic :name => options[:new_category]
    end 

    status = new_topic.save ? :ok : :bad_request 
    head status 
  end 

  def update 
    head :ok
  end 

  def list 
    @categories = BroadTopic.order(:name).all 
    respond_with @categories 
  end 

end
