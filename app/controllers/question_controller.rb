class QuestionController < ApplicationController
  include GeneralQueries
  before_filter :authenticate_account!, except: [:post_compile_updation, :tag, :bundle_which, :set_potd_flag]
  respond_to :json

  def set_potd_flag
    q = Question.find params[:id]
    q.set_potd_flag 
    render json: { id: params[:id] }, status: :ok 
  end 

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

  def hints 
    if params[:sbp].blank? # => question
      q = Question.find params[:id]
      hints = q.nil? ? [] : q.hints 
      @render = {} 
      ids = hints.map(&:subpart_id).uniq
      ids.each do |j| 
        @render["#{j}"] = hints.where(subpart_id: j).order(:index).map(&:text)
      end 
      @id = nil
    else
      sbp = Subpart.find params[:sbp]
      @hints = sbp.hints
      @id = sbp.id 
    end
  end 

  def store_hints 
    id = params[:hint].keys.first.to_i # all hints for the same Subpart. Max. 3. 
    sbp = Subpart.find id 

    # Clear all previous hints. The only reason you're here is because the submit 
    # button was clicked. If you submit, then we can assume that something has changed 
    sbp.hints = []

    hints = params[:hint].values.first # another hash
    hints.each do |k,v| 
      next if v.blank?
      index = k.to_i
      sbp.hints.create text: v, index: index
    end 
    sbp.question.revisions.create(hints: true)
    render json: { status: :ok }, status: :ok
  end 

  def set_topic
    q = Question.find params[:q]
    q.update_attributes(topic_id: params[:t], available: false) unless q.blank?
    render json: { status: :done }, status: :ok
  end 

  def bundle_which
    uid = params[:uid]
    qsn = Question.where(uid: uid).first
    bundleId = ""
    unless qsn.nil?
      bq = BundleQuestion.where(question_id: qsn.id).first
      unless bq.nil?
        bundleId = "#{bq.bundle.uid}|#{bq.label}"
      end
    end
    render json: { bundleId: "#{bundleId}" }, status: :ok
  end

  def tag
    qsn = params[:question]
    question = Question.where(uid: qsn[:uid]).first

    unless question.nil?
      # add question to appropriate bundle(s)
      b = qsn[:bundle]
      unless b.nil?
        uid, label = b.split('|')
        bundle = Bundle.where(uid: uid).first || Bundle.create(uid: uid, auto_download: uid.starts_with?("cbse"))

        bq = BundleQuestion.where(bundle_id: bundle.id, label: label).first
        if bq.nil? # if this qsn has not been tagged already
          bq = BundleQuestion.where(bundle_id: bundle.id, question_id: question.id).first
          if bq.nil?
            bq = BundleQuestion.new question_id: question.id, label: label
            bundle.bundle_questions << bq
          else
            bq.update_attribute :label, label
          end
  
          # delete this question from other bundles
          BundleQuestion.where(question_id: question.id).map { |bqd|
            if bqd.bundle_id != bundle.id
              bqd.delete
            end
          }
          
          bundle.update_zip([bq])
        end
      end

      concepts = qsn[:concepts]
      unless concepts.nil?
        question.concept_list = concepts.join(',')
        question.save()
      end
      render json: { status: :ok, message: 'tagged', uid: bq.question.uid }
    else
      render json: { status: :error, message: 'question not found' }
    end

  end
  
  def tag_old
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
          calculator = misc[:calculator] == "false" ? 0 : 1 
          level = misc[:level]

          # [#108]: New question? Remember to send it for auditing by another examiner
          if question.auditor.nil?
            auditor = Examiner.internal.where{ id != question.examiner_id }.available.map(&:id).sample(1).first
          else
            auditor = question.auditor
          end

          question.update_attributes difficulty: level, answer_key_span: span, available: true,
                                     calculation_aid: calculator, auditor: auditor

          # If the question was sent by a teacher, then update the corresponding 
          # suggestion record. Note that > 1 questions might have been sent in the 
          # same suggestion form. And so, send mail to teacher only when all questions have 
          # been typeset and tagged 

          m = question.suggestion_id.nil? ? nil : Suggestion.where(id: question.suggestion_id).first
          m.check_for_completeness unless m.nil?

          if question.update_subpart_info lengths, marks
            render json: { notify: { text: "#{question.uid} tagged" } }, status: :ok
          else
            render json: { notify: { text: "#{question.uid} subpart tagging failed" } }, status: :bad_request
          end
        else # manifest == nil 
          render json: { notify: { text: "#{question.uid} TeX tagging failed!" } }, status: :bad_request
        end
      else
        render json: { notify: {text: "#{question.uid} Cannot have 0 subparts!" } }, status: :ok
      end # of if nparts > 0
    else
      render json: { notify: { text: "Question not found!" } }, status: :bad_request
    end 
  end # of method 

  def preview
    if params[:type] == 'g' # teacher/student viewing solution
      g = Tryout.find params[:id]
      @question = g.subpart.question
      @version = g.version
    elsif params[:type] == 'stb' # student viewing solution to a stab
      stb = Stab.find params[:id]
      @question = stb.question 
      @version = stb.version
    else # students should never get here 
      is_teacher = current_account.loggable_type == 'Teacher'
      @question = Question.find params[:id]
      @version = params[:v].blank? ? (is_teacher ? "0" : [*0..3]) : params[:v]
    end 
    @context = params[:context] || "unknown" 
  end

  def like
    teacher = current_account.loggable
    qid = params[:id].to_i
    teacher.favourites.create question_id: qid
    render json: { favourite: { id: qid } }, status: :ok
  end

  def commentary 
    q = Question.find params[:id]
    @comments = q.comments 
  end 

  def audit_open
    if params[:type] == 'g'
      g = Tryout.find params[:id]
      subpart_index = g.subpart.index 
      @question = g.subpart.question
    else 
      @question = Question.find params[:id]      
    end 

    unless @question.nil?
      audit_report = params[:audit]

      @gating = audit_report[:gating].select{ |m| !m.blank? }
      @non_gating = audit_report[:non_gating].select{ |m| !m.blank? }
      @comments = audit_report[:comments]

      @comments.prepend("[Part #{subpart_index}]: ") unless subpart_index.nil?

      @question.update_attributes audited_on: Date.today, available: (@gating.count == 0)

      if (@gating.count > 0 || @non_gating.count > 0 || !@comments.blank?)
        @author = Examiner.find @question.examiner_id
        @author = @author.account.active ? @author : Examiner.internal.available.sample(1).first
        
        Mailbot.delay.send_audit_report(@question, @author, @gating, @non_gating, @comments)
      end
      render json: { msg: "Audit Report Sent", disabled: [@question.id] }, status: :ok
    else
      render json: { msg: "Question not found" }, status: :ok
    end
  end 

  def audit_close
    @question = Question.find params[:id]
    unless @question.nil?
      @question.update_attribute(:available, true) unless @question.nil?
      render json: { disabled: [@question.id] }, status: :ok
    else
      render json: { status: :done }, status: :ok
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

  def add_video
    uid = params[:upload][:uid]
    question = Question.find params[:id]

    unless question.nil?
      question.create_video uid: uid, active: true
      render json: { status: :great, hide: [question.id] }, status: :ok
    else
      render json: { status: :failed }, status: :ok
    end
  end

  def layout
    q = Question.find params[:id]
    @subparts = q.subparts
    @context = params[:context]
  end 

  def post_compile_updation 
    # The exact answer key span is what pdfinfo returns during make. 
    # That is the value that should be stored. 
    q = Question.where(uid: params[:q]).first 
    unless q.nil?
      if q.tagged? 
        q.update_attribute(:answer_key_span, params[:n].to_i)
        q.revisions.create(latex: true) 
        unless params[:codex] == 'blank'
          codices = params[:codex].values
          uniques = codices.uniq
          n_codices = uniques.count
          sign = ""
          for m in uniques 
            sign += "#{uniques.index m}"
          end 
          q.update_attributes n_codices: n_codices, codices: sign
        end # unless 
      end # if .. else
    end
    render json: { status: :ok }, status: :ok
  end 

end # of class
