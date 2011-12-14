module WelcomeHelper
  def resource_name 
    :account
  end 

  def resource 
    @resource ||= Account.new
  end 

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:account]
  end 
end
