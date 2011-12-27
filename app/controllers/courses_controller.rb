class CoursesController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json 

  def show 
    @course = Course.find(params[:id]) 
    @syllabi = Syllabus.where(:course_id => @course.id)
    respond_with @course, @syllabi 
  end 

  def update 
    course = Course.find params[:id] 
    status = :ok
    
    status = course.nil? ? :bad_request : 
            (course.update_attributes(params[:course]) ? :ok : :bad_request)
    head status 
  end 

  def search 
    head :ok
  end 

  def create 
   board_name = params[:course].delete :board 
   unless board_name.empty? 
     board = Board.where(:name => board_name).first 
     board = board.nil? ? Board.new(:name => board_name) : board 
     board.save if board.new_record? # Have to save board first else @course.board_id = nil
     @course = board.courses.new params[:course]
   else  
     @course = Course.new params[:course] 
   end 
   @course.save ? respond_with(@course) : head(:bad_request) 
  end 

  def list
    criterion = params[:criterion]
    unless criterion.nil?
      klass = criterion[:klass]
      subject = criterion[:subject]
      board = criterion[:board]
    else
      klass = subject = board = nil
    end 
    @courses = Course.klass?(klass).subject?(subject).board?(board)
  end 

  def coverage
    @course = Course.find params[:id]
    @macros = MacroTopic.where('id IS NOT NULL').order(:name) # basically, everyone
  end 

end
