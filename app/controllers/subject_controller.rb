
class SubjectController < ApplicationController
  respond_to :json 

  def list 
    response = Subject.all.map{ |s| { id: s.id, name: s.name } }
    render json: response, status: :ok 
  end 

end 
