class StudyGroupsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json 

  def create 
    school = School.find params[:id] 
    head :bad_request if school.nil? 

    # {:klasses => {:from => '9', :to => '11'}, :sections => {:from => 'A', :to => 'F'}}
    kfrom = params[:klasses][:from].to_i
    kto = params[:klasses][:to].to_i

    if kfrom > kto 
      x = kfrom 
      kfrom = kto 
      kto = x
    end 
    klasses = [*kfrom..kto]

    sfrom = params[:sections][:from]
    sto = params[:sections][:to]

    if sfrom > sto 
      x = sfrom 
      sfrom = sto 
      sto = x
    end 
    sections = [*sfrom..sto]

    head ( school.create_study_groups(klasses, sections) ? :ok : :bad_request ) 
  end 

end
