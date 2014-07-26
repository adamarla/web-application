class TopicsController < ApplicationController
  include GeneralQueries
  before_filter :authenticate_account!
  respond_to :json

  def create 
    vertical = params[:id]

    unless vertical.nil?
      name = params[:checked][:name]
      unless name.blank?
        vertical = vertical.to_i
        topic = Topic.new :name => name, :vertical_id => vertical
        msg = topic.save ? "New topic added" : "Failed to add topic"
      else
        msg = "Specify name for new  topic"
      end
    else
      msg = "No vertical specified"
    end
    render json: { notify: { text: msg } }, status: :ok
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
    @questions = Question.on_topic(@topic).available

    unless params[:self].blank?
      @questions = @questions.where(examiner_id: current_account.loggable_id)
    end 
    @questions = @questions.order(:id)
    n = @questions.count 

    @per_pg, @last_pg = pagination_layout_details n
    @pg = params[:page].nil? ? 1 : params[:page].to_i
    @questions = @questions.order(:marks).page(@pg).per(@per_pg)
    @context = params[:context]
  end

end
