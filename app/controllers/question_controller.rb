class QuestionController < ApplicationController
  before_filter :authenticate_account!, :except => [:insert_new]
  respond_to :json

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
          @questions = Question.where(:examiner_id => author_id).where('topic_id IS NOT NULL')
        when :any
          @questions = Question.where(:examiner_id => author_id)
        else
          @questions = Question.where(:examiner_id => author_id).where('topic_id IS NULL')
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
