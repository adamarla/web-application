class QuestionController < ApplicationController
  before_filter :authenticate_account!, :except => [:insert_new]
  respond_to :json

  def list
    p = params[:qsearch] 
    p = p.blank? ? {} : p 

    @questions = p[:by].blank? ? Question.author(current_account.loggable_id) 
                               : Question.author(p[:by].to_i)
    @questions = (p[:tagged] == "true") ? @questions.tagged : @questions.untagged
    @questions = p[:on].blank? ? @questions : @questions.broadly_on(p[:on].to_i)

    @questions = p[:difficulty].blank? ? @questions 
                                       : @questions.difficulty(p[:difficulty].to_i)
  end 

  def update
    question = Question.find params[:id]

    unless question.nil?
      values = params[:misc]

      unless values[:num_parts].blank?
        nparts = values[:num_parts].to_i 
        nparts = nparts == 0 ? 1 : nparts # for a standalone question, we still create one sub-part
        lengths = params[:length].values.slice(0, nparts).map(&:to_i)
        marks = params[:marks].values.slice(0, nparts).map(&:to_i)

        # Step 1: Set the marks and lengths in TeX. Only when that succeeds
        # should one update the DB

        manifest = question.edit_tex_layout lengths, marks
        unless manifest.nil?
          # The manifest returns the # of jpegs created - one per page - for
          # this question's answer key. This is something that cannot be calculated
          # because it really depends on how the solution was written for this question
          n_answer_key = manifest[:image].count

          topic = params[:topic].to_i
          difficulty = values[:difficulty].to_i
          calculation_aid = values[:calculation_aid].to_i
          restricted = values[:restricted] == "true" ? true : false

          # 1. Update the parent question
          question.update_attributes :topic_id => topic, :difficulty => difficulty, 
                                     :answer_key_span => n_answer_key, 
                                     :calculation_aid => calculation_aid,
                                     :restricted => restricted

          # If the question was sent by a teacher, then update the corresponding 
          # suggestion record. Note that > 1 questions might have been sent in the 
          # same suggestion form. And so, send mail to teacher only when all questions have 
          # been typeset and tagged 

          m = question.suggestion_id.nil? ? nil : Suggestion.where(:id => question.suggestion_id).first
          m.check_for_completeness unless m.nil?

          if question.update_subpart_info lengths, marks
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
