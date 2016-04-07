
class QuestionController < ApplicationController
  respond_to :json

  def create 
    proceed = !(params[:e].blank? || params[:c].blank?)
    if proceed 
      language = params[:lang] || Language.named('english') 
      difficulty = params[:d] || Difficulty.named('medium')
      q = Question.create examiner_id: params[:e], 
                          chapter_id: params[:c],
                          language_id: language, 
                          difficulty: difficulty
      render json: { id: q.id, path: q.sku.path }, status: :created
    else 
      render json: {id: 0 }, status: :bad_request
    end 
  end 

  def set_skills 
    q = Question.find params[:id] 
    unless q.nil? 
      skill_ids = params[:skills].map(&:to_i) 
      q.set_skills skill_ids 
      render json: { id: q.id }, status: :ok
    else 
      render json: { id: 0 }, status: :bad_request 
    end 
  end # of action 

  def find_with_skills 
    skill_ids = params[:skills].blank? ? [] : params[:skills].map(&:to_i)

    unless skill_ids.blank?
      ques = Question.with_skills(skill_ids)
      render json: { response: ques.map{ |q| {id: q.id, path: q.sku.path } } }, status: :ok  
    else 
      render json: { response: [] }, status: :bad_request 
    end 
  end # of action 

  # ------------

  def new_location 
    response = Question.all.map{ |q| { uid: q.uid, loc: "q/#{q.examiner_id}/#{q.id}" } }
    render json: response, status: :ok
  end 

  def set_potd_flag
    q = Question.find params[:id]
    q.set_potd_flag 
    render json: { id: params[:id] }, status: :ok 
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
        # remove this label from existing bundle
        unless bq.nil?
          bq.delete
        end

        bq = BundleQuestion.where(bundle_id: bundle.id, question_id: question.id).first
        if bq.nil?
          bq = BundleQuestion.new question_id: question.id, label: label
          bundle.bundle_questions << bq
        else
          bq.update_attribute :label, label
        end
  
        # remove this question from any other bundles (1-1 only for now)
        BundleQuestion.where(question_id: question.id).map { |bqd|
          if bqd.bundle_id != bundle.id
            bqd.delete
          end
        }
          
        bundle.update_zip([bq])
      end # end bundle nil check

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

end # of class  
