class QuestionController < ApplicationController
  before_filter :authenticate_account!, :except => [:insert_new]

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

end
