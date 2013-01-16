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

  def tag
    question = Question.find params[:id]

    unless question.nil?
      subparts = params[:subpart]
      nparts = subparts.keys.count
      misc = params[:misc]

      if nparts > 0
        lengths = subparts.map{ |m| m.last[:length].to_i } # :subpart => { 0 => { :length => x, :marks => y }, ... }
        marks = subparts.map{ |m| m.last[:marks].to_i }

        # Step 1: Set the marks and lengths in TeX. Only when that succeeds
        # should one update the DB
        manifest = question.edit_tex_layout lengths, marks

        unless manifest.nil?
          # The manifest returns the # of jpegs created - one per page - for
          # this question's answer key. This is something that cannot be calculated
          # because it really depends on how the solution was written for this question

          span = manifest[:image].count
          topic = params[:topic]
          calculator = misc[:calculator] == "false" ? 0 : 1 
          level = misc[:level]

          # Update the parent question
          question.update_attributes :topic_id => topic, :difficulty => level, 
                                     :answer_key_span => span, :calculation_aid => calculator

          # If the question was sent by a teacher, then update the corresponding 
          # suggestion record. Note that > 1 questions might have been sent in the 
          # same suggestion form. And so, send mail to teacher only when all questions have 
          # been typeset and tagged 

          m = question.suggestion_id.nil? ? nil : Suggestion.where(:id => question.suggestion_id).first
          m.check_for_completeness unless m.nil?

          if question.update_subpart_info lengths, marks
            render :json => { :notify => { :text => "#{question.uid} tagged" } }, :status => :ok
          else
            render :json => { :notify => { :text => "#{question.uid} subpart info update failed" } }, :status => :bad_request
          end
        else 
          render :json => { :notify => { :text => "#{question.uid} TeX tagging failed!" } }, :status => :bad_request 
        end
      end # of if nparts > 0
    else
      render :json => { :notify => { :text => "Tagging failed", :subtext => "Question not in DB" } }, 
             :status => :bad_request
    end 
  end # of method 

  def preview
    @question = Question.find params[:id] 
  end

end # of class
