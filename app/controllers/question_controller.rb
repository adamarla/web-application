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
          #@questions = Question.where(:examiner_id => author_id).where('topic_id IS NOT NULL')
          @questions = Question.where('topic_id IS NOT NULL')
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
      when "1"
        page_length = "mcq"
        mcq, half_page, full_page = true, false, false 
      when "2"
        page_length = "halfpage"
        mcq, half_page, full_page = false, true, false 
      when "3"
        page_length = "fullpage"
        mcq, half_page, full_page = false, false, true 
    end 
    
    # First, issue the Savon request to update the TeX, only then update the DB
    manifest = question.set_length_and_marks page_length, options[:marks]
    unless manifest.nil?
      # Return of the prodigal
      options.merge!({:mcq => mcq, :half_page => half_page, :full_page => full_page})

      if question.update_attributes(options)
        render :json => { :status => 'Done' }, :status => :ok
      else
        render :json => { :status => 'Oops !' }, :status => :bad_request
      end
    end # of unless 
  end

  def preview
    @question = Question.find params[:id] 
  end

end # of class
