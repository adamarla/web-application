class QuestionController < ApplicationController
  before_filter :authenticate_account!, :except => [:insert_new]
  respond_to :json

=begin
  def insert_new
    # As of now, this action can be initiated only by the POST 
    # request sent by 'examiner' script. And the POST request sends 
    # parameters only for :examiner_id, :path and :secret_key (for authentication)
    question = params[:question]
    examiner_id = question[:examiner_id]
    path = question[:path]
    key = question[:secret_key] 

    examiner = Examiner.find examiner_id 
    if examiner
      if examiner.secret_key == key
        new_db_question = Question.new :examiner_id => examiner_id, :path => path
        status = new_db_question.save ? 200 : 400 
      else
        status = 400 
      end 
    else
      status = 400 
    end 
    render :nothing => true, :status => status
  end
=end

  def list
    me = current_account.role
    type = params[:type].blank? ? :untagged : params[:type].to_sym

    case me
      when :admin
        author_id = params[:id].blank? ? current_account.loggable_id : params[:id]
      when :examiner
        author_id = current_account.loggable_id #ignore params[:id] even if specified
      else
        author_id = nil
    end 

    unless author_id.nil?
      case type 
        when :tagged
          @questions = Question.where(:examiner_id => author_id).where('micro_topic_id IS NOT NULL')
        when :any
          @questions = Question.where(:examiner_id => author_id)
        else
          @questions = Question.where(:examiner_id => author_id).where('micro_topic_id IS NULL')
      end
    else
      @questions = []
    end 
  end # of method

  def update
    options = params[:misc]
    question = Question.find options[:id]
    head :bad_request if question.nil? 

    page_length = options.delete :page_length
    case page_length
      when 1 then question.mcq = true 
      when 2 then question.half_page = true
      when 3 then question.full_page = true
    end 

    head question.update_attributes(options) ? :ok : :bad_request
  end

  def preview
    @question = Question.find params[:id] 
  end

end # of class
