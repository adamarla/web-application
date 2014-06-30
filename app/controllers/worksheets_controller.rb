class WorksheetsController < ApplicationController

  def preview 
    w = Worksheet.find params[:id]
    @imgs = w.questions.map(&:uid) 
    v = w.signature.split(',').map{ |j| "/#{j}/notrim.jpg" }
    @imgs.each_with_index do |m,j| 
      @imgs[j] += v[j] 
    end 
  end 

end
