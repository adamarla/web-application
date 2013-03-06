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

  match 'ping' => 'application#ping', :via => :get

  # Account 
  match 'account' => 'accounts#update', :via => :post
  match 'ws/list' => 'accounts#ws', :via => :get
  match 'ws/pending' => 'accounts#pending_ws', :via => :get
  match 'pages/pending' => 'accounts#pending_pages', :via => :get
  match 'gr/pending' => 'accounts#pending_gr', :via => :get
  match 'submit/fdb' => 'accounts#submit_fdb', :via => [:put, :post]
  match 'view/fdb' => 'accounts#view_fdb', :via => :get

  # Admin 
  resource :admin, :controller => :admin 

  # Examiner 
  resource :examiner, :except => [:new, :destroy]
  match 'untagged/list' => 'examiners#untagged', :via => :get
  match 'examiner/block_db_slots' => 'examiners#block_db_slots', :via => :get
  match 'receive/scans' => 'examiners#receive_scans', :via => :get
  match 'examiners/list' => 'examiners#list', :via => :get
  match 'typeset/new' => 'examiners#typeset_new', :via => :get
  match 'typeset/ongoing' => 'examiners#typeset_ongoing', :via => :get
  match 'rotate_scan' => 'examiners#rotate_scan', :via => :get
  match 'restore_scan' => 'examiners#restore_pristine_scan', :via => :get

  # School 
  resource :school, :only => [:show, :create, :update]
  match 'schools/list' => 'schools#list', :via => :get 
  match 'upload_student_list' => 'schools#upload_student_list', :via => :post

  # Verticals 
  resource :vertical, :only => [:create]
  match 'verticals/list' => 'verticals#list', :via => :get
  match 'vertical/topics' => 'verticals#topics', :via => :get

  # Videos 
  resource :video, :only => [:create]
  match 'howtos' => 'videos#howtos'
  match 'video/load' => 'videos#load'

  # Topic 
  resource :topic, :only => [:create, :update]
  match 'topics/list' => 'topics#list', :via => :get
  match 'questions/on' => 'topics#questions', :via => :get

  # Question
  match 'tag/question' => 'question#tag', :via => :post
  match 'questions/list' => 'question#list', :via => :get
  match 'question/preview' => 'question#preview', :via => :get

  # Quiz
  resource :quiz, :only => [:show]
  match 'quizzes/list' => 'quizzes#list', :via => :get
  match 'quiz/preview' => 'quizzes#preview', :via => :get
  match 'quiz/assign' => 'quizzes#assign_to', :via => [:put, :post]
  match 'quiz/testpapers' => 'quizzes#testpapers', :via => :get
  match 'find/schools' => 'schools#find', :via => :get
  match 'quiz/questions' => 'quizzes#questions', :via => :get
  match 'quiz/edit' => 'quizzes#add_remove_questions', :via => [:put, :post]

  # Student 
  resource :student, :only => [:create, :update, :show]
  match 'ws-preview' => 'students#responses', :via => :get
  match 'dispute' => 'students#dispute', :via => :get
  match 'inbox' => 'students#inbox', :via => :get
  match 'inbox/echo' => 'students#inbox_echo', :via => :get
  match 'outbox' => 'students#outbox', :via => :get
  match 'overall/proficiency' => 'students#proficiency', :via => :get

  # Sektion 
  resource :sektion, :only => [:create, :update]
  match 'sektion/students' => 'sektions#students', :via => :get
  match 'sektion/proficiency' => 'sektions#proficiency', :via => :get

  # Teacher 
  resource :teacher, :only => [:create, :update, :show]
  match 'teachers/list' => 'teachers#list', :via => :get
  # match 'teacher/update_roster' => 'teachers#update_roster', :via => [:put, :post]
  match 'teacher/sektions' => 'teachers#sektions', :via => :get
  match 'teacher/load' => 'teachers#load', :via => :get
  match 'teacher/build_quiz' => 'teachers#build_quiz', :via => [:put, :post]
  match 'teacher/ws' => 'teachers#worksheets', :via => :get
  match 'teacher/like_q' => 'teachers#like_question', :via => :get
  match 'teacher/unlike_q' => 'teachers#unlike_question', :via => :get
  match 'teacher/students' => 'teachers#students', :via => :get
  match 'teacher/students_with_names' => 'teachers#students_with_names', :via => :get
  match 'teacher/suggested_questions' => 'teachers#suggested_questions', :via => :get
  match 'disputed' => 'teachers#disputed', :via => :get
  match 'overwrite/marks' => 'teachers#overwrite_marks', :via => [:put, :post]
  match 'qzb/echo' => 'teachers#qzb_echo', :via => [:put, :post]

  # Testpaper
  match 'ws/summary' => 'testpapers#summary', :via => :get
  match 'testpaper/load' => 'testpapers#load', :via => :get
  match 'ws/preview' => 'testpapers#preview', :via => :get
  match 'ws/layout' => 'testpapers#layout', :via => :get
  match 'ws/publish' => 'testpapers#inbox', :via => :get
  match 'ws/unpublish' => 'testpapers#uninbox', :via => :get

  # Trial Account 
  resource :trial_account, :only => [:create], :controller => :trial_account
  
  # Welcome
  match 'about_us' => 'welcome#about_us', :via => :get
  match 'try_us' => 'welcome#try_us', :via => :get
  match 'download' => 'welcome#download', :via => :get
  match 'how_it_works' => 'welcome#how_it_works', :via => :get

  # Suggestion 
  match 'suggestion/block_db_slots' => 'suggestions#block_db_slots', :via => :get
  match 'suggestion/preview' => 'suggestions#preview', :via => :get
  
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
