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

=begin
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
=end
  def update
    question = Question.find params[:id]

    unless question.nil?
      topic = params[:topic].to_i
      values = params[:misc]

      unless values[:num_parts].blank?
        nparts = values[:num_parts].to_i 
        difficulty = values[:difficulty].to_i

        # 1. Update the parent question
        question.update_attributes :topic_id => topic, :difficulty => difficulty

        # 2. Create/remove subparts in the DB as needed. If more subparts are needed then already
        # present in the DB, then create new ones. If fewer subparts are needed, then remove 
        # extra ones
        updated = question.resize_subparts_list_to nparts

        if updated
          lengths = params[:length].values.slice(0, nparts).map(&:to_i)
          marks = params[:marks].values.slice(0, nparts).map(&:to_i)
          question.tag_subparts lengths, marks

          render :json => { :status => 'Done' }, :status => :ok
        else
          render :json => { :status => 'Oops !' }, :status => :bad_request
        end
      else # subpart count missing
        render :json => { :status => "Specify subpart count!"}, :status => :bad_request
      end
    else # unless 
        render :json => { :status => 'Missing Question' }, :status => :bad_request
    end
  end

  def preview
    @question = Question.find params[:id] 
  end

end # of class
