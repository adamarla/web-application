class QuizzesController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def get_candidates
    board = params[:board_id]
    klass = params[:criterion][:klass]
    subject = params[:criterion][:subject]
    topics = params[:checked].keys

    @questions = []
    course = Course.where(:board_id => board, :klass => klass, :subject_id => subject).first 

    head :bad_request if course.nil?

    topics.each do |topic|
      difficulty = Syllabus.where(:course_id => course.id, :micro_topic_id => topic).select(:difficulty).first.difficulty
      @questions |= Question.where(:micro_topic_id => topic, :difficulty => difficulty)
    end 
    respond_with @questions
  end

end
