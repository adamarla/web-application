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

  # Prepwell Pupils 
  match 'pupil/ping' => 'pupils#ping', via: [:get, :post]

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

  # Prepwell per-attempt Podium
  match 'podium/ping' => 'podium#ping', via: :post

  # Prepwell Devices (GCM) 
  match 'device/add' => 'devices#create', via: [:put, :post]
  match 'device/post' => 'devices#post', via: :get

  # Prepwell POTD  
  match 'potd/update' => 'potd#update', via: [:put, :post]

  # Prepwell Analgesics 
  match 'analgesics/add' => 'analgesics#create', via: [:put, :post]

  # Prepwell NotifResponse 
  match 'notif/update' => 'notif_response#update', via: [:put, :post]

  # Prepwell DailyStreaks 
  match 'streak/update' => 'daily_streaks#update', via: [:put, :post]

  # Prepwell Reports
  match 'prepwellapp' => 'welcome#index'
  match 'prepwellapp/report' => 'welcome#report'

  # Subject 
  match 'subject/list' => 'subject#list', via: :get

  # Language 
  match 'language/list' => 'language#list', via: :get

  # Account 
  match 'account' => 'accounts#update', via: :post
  match 'exams/list' => 'accounts#exams', via: :get
  match 'exams/pending' => 'accounts#pending_exams', via: :get
  match 'grade/pending' => 'accounts#to_be_graded', via: :get
  match 'scans/pending' => 'accounts#pending_scans', via: :get
  match 'close/apprentice/audit' => 'accounts#audit_apprentice', via: [:put, :post]
  match 'ping/queue' => 'accounts#poll_delayed_job_queue', via: :get
  match 'byCountry' => 'accounts#by_country', via: :get
  match 'inCountry' => 'accounts#in_country', via: :get
  match 'ask/question' => 'accounts#ask_question', via: :post
  match 'reset/password' => 'accounts#reset_password', via: :post
  match 'quill/signin' => 'accounts#authenticate_for_quill', via: :get

  # Admin 
  resource :admin, :controller => :admin 

  # Examiner 
  resource :examiner, :except => [:new, :destroy]
  match 'examiner/block_db_slots' => 'examiners#block_db_slots', via: :get

  # Verticals 
  resource :vertical, :only => [:create]
  match 'verticals/list' => 'verticals#list', via: :get
  match 'vertical/topics' => 'verticals#topics', via: :get

  # Videos 
  match 'video/play' => 'videos#play'

  # Topic 
  resource :topic, :only => [:create, :update]
  match 'topics/list' => 'topics#list', via: :get
  match 'questions/on' => 'topics#questions', via: :get

  # Question
  match 'question/set_potd_flag' => 'question#set_potd_flag', via: :get
  match 'bundle/which' => 'question#bundle_which', via: :get
  match 'tag/question' => 'question#tag', via: :post

  match 'q/loc' => 'question#new_location', via: :get

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
