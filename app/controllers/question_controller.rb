class QuestionController < ApplicationController
  include GeneralQueries
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
      nparts = subparts.blank? ? 0 : subparts.keys.count
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

          # [#108]: New question? Remember to send it for auditing by another examiner
          if question.auditor.nil?
            auditor = Examiner.available.where{ id != question.examiner_id }.map(&:id).sample(1).first
          else
            auditor = question.auditor
          end

          question.update_attributes :topic_id => topic, :difficulty => level, 
                                     :answer_key_span => span, 
                                     :calculation_aid => calculator,
                                     :auditor => auditor

          # If the question was sent by a teacher, then update the corresponding 
          # suggestion record. Note that > 1 questions might have been sent in the 
          # same suggestion form. And so, send mail to teacher only when all questions have 
          # been typeset and tagged 

          m = question.suggestion_id.nil? ? nil : Suggestion.where(:id => question.suggestion_id).first
          m.check_for_completeness unless m.nil?

          if question.update_subpart_info lengths, marks
            render :json => { 
                              :notify => { 
                                :text => "#{question.uid} tagged" 
                              } 
                            }, :status => :ok
          else
            render :json => { 
                              :notify => { 
                                :text => "#{question.uid} subpart info update failed" 
                              } 
                            }, :status => :bad_request
          end
        else # manifest == nil 
          render :json => { 
                            :notify => { 
                              :text => "#{question.uid} TeX tagging failed!" 
                            } 
                          }, :status => :bad_request 
        end
      else
        render :json => { 
                          :notify => { 
                            :text => "#{question.uid} tagging failed", 
                            :subtext => "Subpart count is zero" 
                          } 
                        }, :status => :ok 
      end # of if nparts > 0
    else
      render :json => { 
                        :notify => { 
                          :text => "Tagging failed", 
                          :subtext => "Question not in DB" 
                        } 
                      }, :status => :bad_request
    end 
  end # of method 

  def preview
    @question = Question.find params[:id] 
    @context = params[:context] || "unknown" 
  end

  def like
    teacher = current_account.loggable
    qid = params[:id].to_i
    teacher.favourites.create :question_id => qid
    render :json => { :favourite => { :id => qid } }, :status => :ok
  end

  def audit 
    gr = params[:gr].to_i
    gr = gr == 0 ? nil : GradedResponse.find(gr) 
    subpart_index = gr.nil? ? nil : [*'A'..'Z'][gr.subpart.index]

    qid = gr.nil? ? params[:id] : gr.subpart.question_id
    @question = Question.find qid

    unless @question.nil?
      audit_report = params[:audit]

      @gating = audit_report[:gating].select{ |m| !m.blank? }
      @non_gating = audit_report[:non_gating].select{ |m| !m.blank? }
      @comments = audit_report[:comments]

      @comments.prepend("[Part #{subpart_index}]: ") unless subpart_index.nil?

      @question.update_attributes :audited_on => Date.today, :available => (@gating.count == 0)

      if (@gating.count > 0 || @non_gating.count > 0 || !@comments.blank?)
        @author = Examiner.find @question.examiner_id
        @author = @author.account.active ? @author : Examiner.available.sample(1).first
        Mailbot.send_audit_report(@question, @author, @gating, @non_gating, @comments).deliver
      end
      render :json => { :msg => "Audit report sent" }, :status => :ok
    else
      render :json => { :msg => "Question not found" }, :status => :ok
    end
  end 

  def without_video
    tagged = Question.author(current_account.loggable_id).tagged
    ids = tagged.map(&:id) - tagged.with_video.map(&:id) 
    @questions = Question.where(id: ids).order(:topic_id)
    n = @questions.count
    pg = params[:page].nil? ? 1 : params[:page].to_i
    @per_pg, @last_pg = pagination_layout_details n
    @questions = @questions.page(pg).per(@per_pg)
  end

end # of class
