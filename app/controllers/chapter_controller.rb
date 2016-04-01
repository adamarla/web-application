
class ChapterController < ApplicationController
  respond_to :json 

  def list 
    level = params[:level] || Level.named('senior') 
    subject = params[:subject] || Subject.named('maths') 
    list = Chapter.where(level_id: level, subject_id: subject).order(:name)
    response = list.blank? ? [] : list.map{ |s| { id: s.id, name: s.name } } 
    render json: response, status: :ok
  end 

end 
