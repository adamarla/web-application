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

  # Account 
  match 'account' => 'accounts#update', via: :post
  match 'ws/list' => 'accounts#ws', via: :get
  match 'ws/pending' => 'accounts#pending_ws', via: :get
  match 'pages/pending' => 'accounts#pending_pages', via: :get
  match 'gr/pending' => 'accounts#pending_gr', via: :get
  match 'submit/fdb' => 'accounts#submit_fdb', via: [:put, :post]
  match 'view/fdb' => 'accounts#view_fdb', via: :get
  match 'ping/queue' => 'accounts#poll_delayed_job_queue', via: :get
  match 'byCountry' => 'accounts#by_country', via: :get
  match 'inCountry' => 'accounts#in_country', via: :get
  match 'ask/question' => 'accounts#ask_question', via: :post
  match 'merge/accounts' => 'accounts#merge', via: :post

  # Admin 
  resource :admin, :controller => :admin 

  # Course
  match 'course/new' => 'course#create', via: :post
  match 'course/all' => 'course#show', via: :get
  match 'milestone/load' => 'course#load_milestone', via: :get
  match 'available/assets' => 'course#available_assets', via: :get
  match 'attach_detach_asset' => 'course#attach_detach_asset', via: :post

  # Examiner 
  resource :examiner, :except => [:new, :destroy]
  match 'untagged/list' => 'examiners#untagged', via: :get
  match 'examiner/block_db_slots' => 'examiners#block_db_slots', via: :get
  match 'distribute/scans' => 'examiners#distribute_scans', via: :get
  match 'examiners/list' => 'examiners#list', via: :get
  match 'typeset/new' => 'examiners#typeset_new', via: :get
  match 'typeset/ongoing' => 'examiners#typeset_ongoing', via: :get
  match 'rotate_scan' => 'examiners#rotate_scan', via: :get
  match 'restore_scan' => 'examiners#restore_pristine_scan', via: :get
  match 'pages/unresolved' => 'examiners#unresolved_scans', via: :get
  match 'unresolved/preview' => 'examiners#preview_unresolved', via: :get
  match 'resolve' => 'examiners#resolve_scan', via: :post
  match 'update_scan_id' => 'examiners#update_scan_id', via: :get
  match 'update_scan_id' => 'examiners#update_scan_id', via: :post
  match 'audit/pending' => 'examiners#audit', via: :get
  match 'audit/close' => 'examiners#audit_closure_required', via: :get

  # School 
  resource :school, :only => [:show, :create, :update]
  match 'upload_student_list' => 'schools#upload_student_list', via: :post

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
  match 'tag/question' => 'question#tag', via: :post
  match 'questions/list' => 'question#list', via: :get
  match 'question/preview' => 'question#preview', via: :get
  match 'like' => 'question#like', via: :get
  match 'audit/done' => 'question#audit', via: :post
  match 'questions/without_video' => 'question#without_video', via: :get
  match 'question/add_video' => 'question#add_video', via: :post

  # Quiz
  resource :quiz, :only => [:show]
  match 'quizzes/list' => 'quizzes#list', via: :get
  match 'quiz/preview' => 'quizzes#preview', via: :get
  match 'quiz/assign' => 'quizzes#assign_to', via: [:put, :post]
  match 'quiz/testpapers' => 'quizzes#testpapers', via: :get
  match 'find/schools' => 'schools#find', via: :get
  match 'quiz/questions' => 'quizzes#questions', via: :get
  match 'quiz/edit' => 'quizzes#add_remove_questions', via: [:put, :post]

  # Student 
  resource :student, :only => [:update, :show]
  match 'register/student' => 'students#create', via: :post
  match 'ws-preview' => 'students#responses', via: :get
  match 'dispute' => 'students#dispute', via: :get
  match 'inbox' => 'students#inbox', via: :get
  match 'inbox/echo' => 'students#inbox_echo', via: :get
  match 'outbox' => 'students#outbox', via: :get
  match 'overall/proficiency' => 'students#proficiency', via: :get
  match 'enroll' => 'students#enroll', via: :post

  # Sektion 
  match 'sektion/students' => 'sektions#students', via: :get
  match 'sektion/proficiency' => 'sektions#proficiency', via: :get
  match 'add/sektion' => 'sektions#create', via: :post
  match 'update/sektion' => 'sektions#update', via: :post
  match 'ping/sektion' => 'sektions#ping', via: :get
  match 'preview/names' => 'sektions#preview_names', via: :post
  match 'enroll/named' => 'sektions#enroll_named_students', via: :post

  # Teacher 
  resource :teacher, :only => [:update, :show]
  match 'register/teacher' => 'teachers#create', via: :post
  match 'teachers/list' => 'teachers#list', via: :get
  match 'teacher/sektions' => 'teachers#sektions', via: :get
  match 'teacher/load' => 'teachers#load', via: :get
  match 'teacher/build_quiz' => 'teachers#build_quiz', via: [:put, :post]
  match 'teacher/ws' => 'teachers#worksheets', via: :get
  match 'teacher/students' => 'teachers#students', via: :get
  match 'teacher/students_with_names' => 'teachers#students_with_names', via: :get
  match 'teacher/suggested_questions' => 'teachers#suggested_questions', via: :get
  match 'disputed' => 'teachers#disputed', via: :get
  match 'overwrite/marks' => 'teachers#overwrite_marks', via: [:put, :post]
  match 'qzb/echo' => 'teachers#qzb_echo', via: [:put, :post]
  match 'prefab' => 'teachers#prefabricate', via: :post
  match 'new/lesson' => 'teachers#add_lesson', via: :post

  # Testpaper
  match 'ws/summary' => 'testpapers#summary', via: :get
  match 'testpaper/load' => 'testpapers#load', via: :get
  match 'ws/preview' => 'testpapers#preview', via: :get
  match 'ws/layout' => 'testpapers#layout', via: :get
  match 'ws/publish' => 'testpapers#inbox', via: :get
  match 'ws/unpublish' => 'testpapers#uninbox', via: :get

  # Welcome
  match 'welcome/countries' => 'welcome#countries', via: :get
  match 'faq' => 'welcome#faq'

  # Suggestion 
  resource :suggestion, :only => [:create]
  match 'suggestion/block_db_slots' => 'suggestions#block_db_slots', via: :get
  match 'suggestion/preview' => 'suggestions#preview', via: :get

  # Token
  resources :tokens, :only => [:create, :destroy]
  match 'tokens/verify' => 'tokens#verify', via: :get
  
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
