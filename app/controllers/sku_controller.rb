
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
    c = params[:c].blank? ? 0 : params[:c].to_i 
    listing = Sku.in_chapter(c) 

    response = listing.map{ |sku| obj = sku.stockable ; 
                                  { id: obj.is_a?(Skill) ? obj.id : obj.get_id, 
                                    path: sku.path,
                                    authorId: obj.author_id, 
                                    chapterId: c, 
                                    assetClass: obj.class.name } }

    render json: response, status: :ok
  end 

end # of class 
