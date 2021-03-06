Webapp::Application.routes.draw do

  # post "question/insert_new"

  # The :path_prefix is important to disambiguate paths devise creates 
  # from ones that one would create if he/she wants to update their own 
  # Account model. For example, to edit the email field in our own model,
  # we need a controller & controller actions. Paths corresponding them 
  # would be quite similar - if not the same - as those created by devise below

  devise_for :accounts, :path_prefix => 'gutenberg' do 
    get '/login' => 'devise/sessions#new'
    get '/logout' => 'devise/sessions#destroy'
  end 

  match 'ping' => 'application#ping', via: :get

  #### Needed on website

    match 'measureapp' => 'welcome#index'
    match 'measureapp/report' => 'welcome#report'

  #### Needed in experimental release 'evident'
    match 'activity/update' => 'activity#update', via: :post

  #### NEEDED IN THE MOBILE APP  

    # Users 
    match 'user/ping' => 'users#ping', via: [:get, :post]
    match 'pupil/ping' => 'users#ping', via: [:get, :post] # temporary alias for backward compatibility 

    # Devices (GCM) 
    match 'device/add' => 'devices#create', via: [:put, :post]
    match 'device/post' => 'devices#post', via: :get

    # Parcels 
    match 'next/zip' => 'parcels#next_zip', via: [:get, :post]

    # Usage metrics  
    match 'usage/update' => 'usages#update', via: [:put, :post]
    match 'usage/daily' => 'usages#daily', via: :get
    match 'usage/by_user' => 'usages#by_user', via: :get

    # Expertise 
    match 'expertise/ping' => 'expertise#ping', via: [:get, :post]
    match 'expertise/update' => 'expertise#update', via: :post 

    # Zips
    match 'zip/ping' => 'zip#ping', via: [:get, :post] 

    # Willingness to Pay (WTP)
    match 'wtp/update' => 'wtp#update', via: [:get, :post]
    match 'wtp/by_user' => 'wtp#get_by_user', via: :get

  #### NEEDED IN QUILL / SCRIBBLER 

    # Account 
    match 'quill/signin' => 'authors#authenticate', via: :get

    # Author 
    match 'author/list' => 'authors#list', via: :get

    # Chapter 
    match 'chapter/list' => 'chapter#list', via: :get

    # Difficulty 
    match 'difficulty/list' => 'difficulty#list', via: :get

    # Language 
    match 'language/list' => 'language#list', via: :get

    # Grade 
    match 'grades/list' => 'grades#list', via: :get

    # Question
    match 'question/add' => 'question#create', via: [:get, :post]
    match 'question/list' => 'question#list', via: :get
    match 'question/set_chapter' => 'question#set_chapter', via: [:get, :post]

    # Skills 
    match 'skill/add' => 'skills#create', via: [:get, :post]
    match 'skill/update' => 'skills#update', via: [:get, :post]
    match 'skill/set_chapter' => 'skills#set_chapter', via: [:get, :post]
    match 'skills/list' => 'skills#list', via: :get
    match 'skills/all' => 'skills#all', via: :get
    match 'missing/skills' => 'skills#missing', via: [:get, :post]
    match 'skills/ping' => 'skills#ping', via: [:get, :post]

    # SKU
    match 'sku/list' => 'sku#list', via: [:get]
    match 'sku/block' => 'sku#block', via: :get 
    match 'sku/update_eps_count' => 'sku#update_eps_count', via: :get

    # Subject 
    match 'subject/list' => 'subject#list', via: :get

    # Snippets 
    match 'snippet/add' => 'snippets#create', via: [:get, :post]
    match 'snippets/list' => 'snippets#list', via: :get
    match 'snippet/set_chapter' => 'snippets#set_chapter', via: [:get, :post]


  #### NEEDED IN BASH SCRIPTS / CRON-JOBS 

    # Chapter 
    match 'chapter/parcels' => 'chapter#parcels', via: :get
    match 'chapter/inventory' => 'chapter#inventory', via: :get

    # Parcels 
    match 'modified/parcels' => 'parcels#list_modified_parcels', via: :get
    match 'modified/zips' => 'parcels#list_modified_zips', via: :get

    # Skills 
    match 'skills/revaluate' => 'skills#revaluate', via: :get

    # SKU 
    match 'sku/update' => 'sku#update', via: [:get]

    # User
    match 'users/csv' => 'users#csv_list', via: :get

    # Zips 
    match 'update/zip' => 'zip#update', via: :get
    match 'zip/contents' => 'zip#list_contents', via: :get

  #### DEPRECATED (Can be commented out one-by-one) 

    # Prepwell Bundles 
    match 'bundle/ping' => 'bundles#ping', via: [:get, :post]
    match 'bundle/update' => 'bundles#update', via: [:put, :post]
    match 'bundle/questions' => 'bundles#questions', via: [:get]
    match 'bundle/fetch_all' => 'bundles#fetch_all', via: [:get]

    # Prewell Attempts 
    match 'update/attempt' => 'attempts#update', via: [:put, :post]
    match 'attempt/by_day' => 'attempts#by_day', via: [:get]
    match 'attempt/by_week' => 'attempts#by_week', via: [:get]
    match 'attempt/by_user' => 'attempts#by_user', via: [:get]

    # Account 
    match 'ping/queue' => 'accounts#poll_delayed_job_queue', via: :get

    # Welcome
    match 'welcome/countries' => 'welcome#countries', via: :get
    match 'faq' => 'welcome#faq'
  
  root :to => "welcome#index"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
