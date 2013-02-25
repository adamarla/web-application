class TopicsController < ApplicationController
  include GeneralQueries
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

  def questions
    @topic = params[:id].to_i
    @questions = Question.where(:topic_id => @topic) 
    n = @questions.count 

    @per_pg, @last_pg = pagination_layout_details n
    @pg = params[:page].nil? ? 1 : params[:page].to_i
    @questions = @questions.order(:marks).page(@pg).per(@per_pg)
    @context = params[:context]
  end

end
