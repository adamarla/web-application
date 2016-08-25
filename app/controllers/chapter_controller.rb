
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

  # To be called ** only **  by the bash script 'inventory' 
  def inventory 
    chapter_ids = Chapter.all.map(&:id) - [29] 
    xi = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17]
    xii = [18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28]

    ret = [] 
    chapter_ids.each do |cid| 
      inv = {} 
      chapter = Chapter.find cid 
      parcels = Parcel.where(chapter_id: cid) 

      inv[:one] = chapter.name
      inv[:two] = cid 
      inv[:three] = xii.include?(cid) ? "12" : (xi.include?(cid) ? "11" : "NA")
      inv[:four] = parcels.where(contains: "Question").first.zips.map(&:sku_ids).flatten.count 
      inv[:five] = parcels.where(contains: "Snippet").first.zips.map(&:sku_ids).flatten.count 
      inv[:six] = parcels.where(contains: "Skill").first.zips.map(&:sku_ids).flatten.count 

      ret.push inv
    end 

    ret.unshift({ one: 'Name', two: 'Chapter ID', three: 'Grade', four: '# Questions', five: '# Snippets', six: '# Skills' })
    render json: ret, status: :ok

  end 

end 
