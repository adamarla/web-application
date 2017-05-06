
class SkuController < ApplicationController

  def update 
    # Note: Any source.tex written before April'17 will generate 
    # a layout.xml with no <skill> tags *if recompiled* today.

    # This is a problem - if a Riddle. And the only solution is to 
    # add \setskills{...} to the Riddle's source.tex. 

    # This also means that if any such source.tex is recompiled, then
    # we would get any empty skill-list here. But we preserve any 
    # previously set skills to help with the re-tagging issue 
    # mentioned above. 

    sku = Sku.with_path params[:path]
    obj = sku.nil? ? nil : sku.stockable

    if obj.nil?
      render json: { id: 0 }, status: :bad_request 
    else 
      # Asset compiled. Hence, mark it as having SVGs
      obj.has_svgs ? sku.tag_modified_zips : obj.update_attribute(:has_svgs, true)

      if obj.is_a?(Skill)
        render json: { id: obj.id }, status: :ok
      else 
        ids = params[:skills].split(",").map(&:to_i).uniq
        obj.set_skills(ids) unless ids.blank?
        render json: { id: obj.get_id }, status: :ok
      end 
    end 
  end # of method 
  
  def list 
    last = params[:last].blank? ? 0 : params[:last].to_i 
    list = Sku.where('id > ?', last) 

    resp = list.map{ |sku| sku.decompile }
    render json: resp.select{ |j| !j[:chapter].nil? }, status: :ok
  end 

  def block 
    # Request comes from Scribbler. You can assume it 
    # is formed correctly

    # Triggerred only *after* draft successfully scanned. 
    # No draft => no slot!!
    
    type = params[:type].to_i 
    author = params[:author].to_i 
    chapter = params[:chapter].to_i 

    fields = { chapter_id: chapter, 
               author_id: author, 
               has_draft: true }

    case type
      when 1 
        obj = Question.create(fields)
      when 2 
        obj = Snippet.create(fields)
      when 4 
        obj = Skill.create(fields)
      else 
        obj = nil 
    end 

    unless obj.nil?
      render json: [obj.sku.decompile], status: :ok 
    else 
      render json: [{ id: 0 }], status: :bad_request 
    end 
  end 

end # of class 
