
class ChapterController < ApplicationController
  respond_to :json 

  def list 
    if params[:cmdline]
      level = Level.named params[:level]
      subject = Subject.named params[:subject]
    else 
      level = params[:level] || Level.named('senior') 
      subject = params[:subject] || Subject.named('maths') 
    end 

    list = Chapter.where(level_id: level, subject_id: subject).order(:name)
    response = list.blank? ? [] : list.map{ |s| { id: s.id, name: s.name } } 
    render json: response, status: :ok
  end 

  # To be called ** only ** by the bash script called 'syllabus'
  def parcels
    parcels = Parcel.where(chapter_id: params[:c]) 
    render json: parcels.map(&:to_json), status: :ok
  end 

end 
