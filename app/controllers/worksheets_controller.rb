class WorksheetsController < ApplicationController

  def preview 
    w = Worksheet.find params[:id]
    @imgs = w.questions.map(&:uid) 
    v = w.signature.split(',').map{ |j| "/#{j}/notrim.jpg" }
    @imgs.each_with_index do |m,j| 
      @imgs[j] += v[j] 
    end 
  end 

  def scans
    w = Worksheet.find params[:id]
    a = w.attempts.with_scan
    unless a.blank? 
      @imgs = a.map(&:scan).uniq
    else 
      @imgs = []
    end 
  end

end