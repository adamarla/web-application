
class LanguageController < ApplicationController
  respond_to :json 

  def list 
    response = Language.all.map{ |l| { id: l.id, name: l.name } }
    render json: response, status: :ok 
  end 

end 
