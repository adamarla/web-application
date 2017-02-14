
class ChapterController < ApplicationController
  respond_to :json 

  def list 
    level = params[:level].blank? ? Level.named('senior') : params[:level] 
    subject = params[:subject].blank? ? Subject.named('maths') : params[:subject]

    list = Chapter.where(level_id: level, subject_id: subject).order(:name)
    response = list.blank? ? [] : list.map{ |c| { id: c.id, name: c.name, friend_id: c.friend_id } } 
    render json: response, status: :ok
  end 

  # To be called ** only ** by the bash script called 'syllabus'
  def parcels
    chapter = Chapter.find params[:c]
    parcels = chapter.parcels  
    parcels = params[:skill] == "true" ? parcels.where('skill_id > ? OR contains = ?', 0, "Skill") : parcels 

    render json: parcels.map(&:to_json), status: :ok
  end 

  # To be called ** only **  by the bash script 'inventory' 
  def inventory 
    chapter_ids = Chapter.all.map(&:id) - [29] 
    xi = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17]
    xii = [18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28]

    ret = [] 
    chapter_ids.each do |cid| 
      inv = {} 
      chapter = Chapter.find cid 
      parcels = Parcel.where(chapter_id: cid, skill_id: 0) 

      inv[:one] = chapter.name
      inv[:two] = cid 
      inv[:three] = xii.include?(cid) ? 12 : (xi.include?(cid) ? 11 : -1)
      inv[:four] = parcels.where(contains: "Question").first.zips.map(&:sku_ids).flatten.count 
      inv[:five] = parcels.where(contains: "Snippet").first.zips.map(&:sku_ids).flatten.count 
      inv[:six] = parcels.where(contains: "Skill").first.zips.map(&:sku_ids).flatten.count 

      ret.push inv
    end 

    ret.unshift({ one: 'Name', two: 'Chapter ID', three: 'Grade', four: "Questions", five: "Snippets", six: "Skills" })
    render json: ret, status: :ok

  end 

end 
