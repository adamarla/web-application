
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
    last = params[:last].blank? ? 0 : params[:last].to_i 
    list = Sku.where('id > ?', last) 

    resp = list.map{ |sku| obj = sku.stockable ;
      {
        id: sku.id, 
        db_id: sku.stockable_id,  
        type: obj.is_a?(Question) ? 1 : (obj.is_a?(Snippet) ? 2 : 4),
        chapter: obj.chapter_id, 
        author: obj.author_id, 
        path: sku.path, 
        has_tex: obj.has_svgs } }

     render json: resp.select{ |j| !j[:chapter].nil? }, status: :ok
  end 

=begin
  def list 
    c = params[:c].blank? ? 0 : params[:c].to_i 
    listing = Sku.in_chapter(c) 

    response = listing.map{ |sku| obj = sku.stockable ; 
                                  { id: obj.is_a?(Skill) ? obj.id : obj.get_id, 
                                    path: sku.path,
                                    authorId: obj.author_id, 
                                    chapterId: c, 
                                    assetClass: obj.class.name,
                                    hasSvgs: obj.has_svgs } }

    render json: response, status: :ok
  end 
=end

end # of class 
