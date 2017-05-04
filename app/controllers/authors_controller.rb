
class AuthorsController < ApplicationController
  respond_to :json 

  def authenticate 
    a = params[:email].blank? ? nil : Author.where(email: params[:email]).first 
    unless a.nil?
      render json: { allow: a.live, 
                     name: a.name, 
                     id: a.id, 
                     role: a.is_admin ? "Admin" : "Author" }, status: :ok
    else
      render json: { allow: false }, status: :ok
    end 
  end 

  def list
    last = params[:last].blank? ? 0 : params[:last].to_i 
    authors = Author.where('is_admin = ? OR id > ?', true, 19).where('id > ?', last) 

    render json: authors.map{ |a| {
      id: a.id, 
      name: a.name, 
      email: a.email, 
      is_admin: a.is_admin } }, status: :ok
  end

end # of controller class
