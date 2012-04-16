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
    question = Question.find params[:id]

    unless question.nil?
      values = params[:misc]

      unless values[:num_parts].blank?
        nparts = values[:num_parts].to_i 
        lengths = params[:length].values.slice(0, nparts).map(&:to_i)
        marks = params[:marks].values.slice(0, nparts).map(&:to_i)

        # Step 1: Set the marks and lengths in TeX. Only when that succeeds
        # should one update the DB

        manifest = question.set_length_and_marks lengths, marks
        unless manifest.nil?
          topic = params[:topic].to_i
          difficulty = values[:difficulty].to_i

          # 1. Update the parent question
          question.update_attributes :topic_id => topic, :difficulty => difficulty

          # 2. Create/remove subparts in the DB as needed. If more subparts are needed then already
          # present in the DB, then create new ones. If fewer subparts are needed, then remove 
          # extra ones
          updated = question.resize_subparts_list_to nparts

          if updated
            question.tag_subparts lengths, marks
            render :json => { :status => 'Done' }, :status => :ok
          else
            render :json => { :status => 'Oops !' }, :status => :bad_request
          end
        else # Savon request error !!
          render :json => { :status => 'Tagging failed!' }, :status => :bad_request
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
