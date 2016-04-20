
class ExaminersController < ApplicationController
  respond_to :json 

  def list
    examiners = Examiner.order(:id).map{ |e| { id: e.id, name: e.name } }
    render json: examiners, status: :ok
  end

  def block_db_slots
    examiner = Examiner.find params[:id]
    unless examiner.nil? 
      slots = examiner.block_db_slots
      render json: { notify: { text: "10 slots blocked" } }, status: :ok 
    else 
      render json: { notify: { text: "No such examiner" } }, status: :ok
    end 
  end

end # of controller class
