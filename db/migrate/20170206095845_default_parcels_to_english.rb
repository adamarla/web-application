class DefaultParcelsToEnglish < ActiveRecord::Migration
  def change 
    language = Language.named 'English' 
    change_column_default :parcels, :language_id, language 
  end 
end
