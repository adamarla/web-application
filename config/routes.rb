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
  match 'prepwellapp' => 'welcome#index'

  # Prepwell Pupils 
  match 'pupil/ping' => 'pupils#ping', via: [:get, :post]

  # Prepwell Bundles 
  match 'bundle/ping' => 'bundles#ping', via: [:get, :post]
  match 'bundle/update' => 'bundles#update', via: [:put, :post]
  match 'bundle/questions' => 'bundles#questions', via: [:get]
  match 'bundle/fetch_all' => 'bundles#fetch_all', via: [:get]

  # Prewell Attempts 
  match 'update/attempt' => 'attempts#update', via: [:put, :post]

  # Prepwell Devices (GCM) 
  match 'device/add' => 'devices#create', via: [:put, :post]
  match 'device/post' => 'devices#post', via: :get

  # Prepwell POTD  
  match 'potd/update' => 'potd#update', via: [:put, :post]

  # Prepwell Analgesics 
  match 'analgesics/add' => 'analgesics#create', via: [:put, :post]

  # Prepwell NotifResponse 
  match 'notif/update' => 'notif_response#update', via: [:put, :post]

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

  # Admin 
  resource :admin, :controller => :admin 

  # Course
  match 'course/new' => 'course#create', via: :post
  match 'course/list' => 'course#list', via: :get
  match 'course/quizzes' => 'course#quizzes', via: :get
  match 'course/lessons' => 'course#lessons', via: :get
  match 'course/update' => 'course#update', via: :post
  match 'ping/course' => 'course#ping', via: :get
  match 'load/course' => 'course#load', via: :get

  # Doubts 
  match 'doubts/pending' => 'doubts#pending', via: :get
  match 'doubt/preview' => 'doubts#preview', via: :get
  match 'doubt/refund' => 'doubts#refund', via: :get
  match 'tag/doubt' => 'doubts#tag', via: :post 

  # Examiner 
  resource :examiner, :except => [:new, :destroy]
  match 'untagged/list' => 'examiners#untagged', via: :get
  match 'examiner/block_db_slots' => 'examiners#block_db_slots', via: :get
  match 'distribute/scans' => 'examiners#distribute_scans', via: :get
  match 'examiners/list' => 'examiners#list', via: :get
  match 'typeset/new' => 'examiners#typeset_new', via: :get
  match 'typeset/ongoing' => 'examiners#typeset_ongoing', via: :get
  match 'rotate_scan' => 'examiners#rotate_scan', via: :get
  match 'pages/unresolved' => 'examiners#unresolved_scans', via: :get
  match 'unresolved/preview' => 'examiners#preview_unresolved', via: :get
  match 'resolve' => 'examiners#resolve_scan', via: :post
  match 'update_scan_id' => 'examiners#receive_single_scan', via: :post
  match 'audit/todo' => 'examiners#audit_todo', via: :get
  match 'audit/review' => 'examiners#audit_review', via: :get
  match 'examiner/apprentices' => 'examiners#apprentices', via: :get
  match 'load/samples' => 'examiners#load_samples', via: :get

  match 'disputes' => 'examiners#disputed', via: :get
  match 'load/dispute' => 'examiners#load_dispute', via: :get
  match 'dispute/reject' => 'examiners#reject_dispute', via: [:put, :post] 
  match 'dispute/accept' => 'examiners#accept_dispute', via: :get
  match 'dispute/reason' => 'examiners#load_dispute_reason', via: :get

  match 'mail/digest' => 'examiners#daily_digest', via: :get

  match 'reset/graded' => 'examiners#reset_graded', via: :get
  match 'aggregate' => 'examiners#aggregate', via: :get
  match 'germane/comments' => 'examiners#germane_comments', via: :get

  match 'load/rubric/for' => 'examiners#load_rubric', via: :get

  # Attempt 
  match 'record/fdb' => 'tryouts#grade', via: [:put, :post]
  match 'load/fdb' => 'tryouts#load_fdb', via: :get
  match 'reupload' => 'tryouts#reupload', via: :post

  # Stab
  match 'stab/ping' => 'stabs#ping', via: :get
  match 'stab/dates' => 'stabs#dates', via: :get
  match 'stabs/dated' => 'stabs#dated', via: :get
  match 'grade/stab' => 'stabs#grade', via: [:put, :post]
  match 'stabs/graded' => 'stabs#graded', via: :get
  match 'stab/load' => 'stabs#load', via: :get
  match 'stab/bell-curve' => 'stabs#bell_curve', via: :get

  # Guardian
  resource :guardian, :only => [:show]
  match 'register/guardian' => 'guardians#create', via: :post
  match 'guardian/add_student' => 'guardians#add_student', via: :get
  match 'guardian/students' => 'guardians#students', via: :get

  # School 
  resource :school, :only => [:show, :create, :update]
  match 'schools/list' => 'schools#list', via: :get
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

  # Puzzle 
  match 'puzzle/add' => 'puzzles#create', via: :post 
  match 'puzzle/load' => 'puzzles#load', via: :get 
  match 'puzzle/next' => 'puzzles#next', via: :get 

  # Question
  match 'question/set_potd_flag' => 'question#set_potd_flag', via: :get
  match 'bundle/which' => 'question#bundle_which', via: :get
  match 'tag/question' => 'question#tag', via: :post
  match 'questions/list' => 'question#list', via: :get
  match 'question/preview' => 'question#preview', via: :get
  match 'like' => 'question#like', via: :get
  match 'audit/open' => 'question#audit_open', via: :post
  match 'audit/close' => 'question#audit_close', via: :get
  match 'questions/without_video' => 'question#without_video', via: :get
  match 'question/add_video' => 'question#add_video', via: :post
  match 'set/topic' => 'question#set_topic', via: :get
  match 'question/layout' => 'question#layout', via: :get
  match 'load/hints' => 'question#hints', via: :get
  match 'store/hints' => 'question#store_hints', via: [:put, :post]
  match 'question/commentary' => 'question#commentary', via: :get
  match 'update/on_make' => 'question#post_compile_updation', via: :get

  # Quiz
  resource :quiz, :only => [:show]
  match 'quiz/daily' => 'quizzes#daily', via: :get 
  match 'quizzes/list' => 'quizzes#list', via: :get
  match 'quiz/preview' => 'quizzes#preview', via: :get
  match 'quiz/mass_assign' => 'quizzes#mass_assign_to', via: [:put, :post]
  match 'quiz/exams' => 'quizzes#exams', via: :get
  match 'find/schools' => 'schools#find', via: :get
  match 'quiz/questions' => 'quizzes#questions', via: :get
  match 'quiz/edit' => 'quizzes#add_remove_questions', via: [:put, :post]
  match 'share/quiz' => 'quizzes#share', via: :post
  match 'quiz/build' => 'quizzes#build', via: [:put, :post]
  match 'ping/quiz' => 'quizzes#ping', via: :get
  match 'grade/quiz' => 'quizzes#pay_to_grade', via: :get

  # Student 
  resource :student, :only => [:update, :show]
  match 'register/student' => 'students#create', via: :post
  match 'match/student' => 'students#match', via: :post
  match 'inbox' => 'students#inbox', via: :get
  match 'outbox' => 'students#outbox', via: :get
  match 'dispute' => 'students#dispute', via: [:put, :post] 
  match 'merge' => 'students#merge', via: [:post, :put]

  # Worksheets 
  match 'worksheet/preview' => 'worksheets#preview', via: :get
  match 'worksheet/scans' => 'worksheets#scans', via: :get

  # Sektion 
  match 'sektion/students' => 'sektions#students', via: :get
  match 'sektion/proficiency' => 'sektions#proficiency', via: :get
  match 'add/sektion' => 'sektions#create', via: :post
  match 'update/sektion' => 'sektions#update', via: :post
  match 'ping/sektion' => 'sektions#ping', via: :get
  match 'preview/names' => 'sektions#preview_names', via: :post
  match 'enroll/named' => 'sektions#enroll_named_students', via: :post
  match 'ping/for/phones' => 'sektions#ping_for_phones', via: [:put, :post]
  match 'update/phones' => 'sektions#update_phones', via: [:put, :post]
  match 'sektions/monthly_audit' => 'sektions#monthly_audit', via: :get

  # Teacher 
  resource :teacher, :only => [:update, :show]
  match 'teachers/list' => 'teachers#list', via: :get
  match 'teacher/sektions' => 'teachers#sektions', via: :get
  match 'teacher/load' => 'teachers#load', via: :get
  match 'teacher/ws' => 'teachers#worksheets', via: :get
  match 'teacher/students' => 'teachers#students', via: :get
  match 'teacher/suggested_questions' => 'teachers#suggested_questions', via: :get
  match 'qzb/echo' => 'teachers#qzb_echo', via: [:put, :post]
  match 'new/lesson' => 'teachers#add_lesson', via: :post
  # match 'prefab' => 'teachers#prefabricate', via: [:put, :post]
  match 'overall/proficiency' => 'teachers#proficiency_chart', via: :get
  match 'def/dist/scheme' => 'teachers#def_distribution_scheme', via: :get
  match 'set/dist/scheme' => 'teachers#set_distribution_scheme', via: [:put, :post]
  match 'lessons/list' => 'teachers#lessons', via: :get
  match 'teacher/courses' => 'teachers#courses', via: :get
  match 'teacher/digest' => 'teachers#send_digest', via: :get

  # Exam
  match 'exam/summary' => 'exams#summary', via: :get
  match 'exam/load' => 'exams#load', via: :get
  match 'exam/layout' => 'exams#layout', via: :get
  match 'ws/publish' => 'exams#inbox', via: :get
  match 'ws/unpublish' => 'exams#uninbox', via: :get
  match 'ws/report_card' => 'exams#report_card', via: :get
  match 'ws/update_signature' => 'exams#update_signature', via: :get
  match 'exam/disputes/pending' => 'exams#pending_disputes', via: :get
  match 'exam/disputes/resolved' => 'exams#resolved_disputes', via: :get
  match 'set/deadlines' => 'exams#deadlines', via: [:put, :post]
  match 'ping/exam' => 'exams#ping', via: :get

  # Rubrics 
  resource :rubric, controller: :rubrics, only: [:create]
  match 'rubric/update' => 'rubrics#update', via: :post
  match 'list/rubrics' => 'rubrics#list', via: :get
  match 'rubric/load' => 'rubrics#load', via: :get
  match 'activate/rubric' => 'rubrics#activate', via: :get

  # Criterion
  resource :criterion, controller: :criteria, only: [ :create ]

  # Welcome
  match 'welcome/countries' => 'welcome#countries', via: :get
  match 'faq' => 'welcome#faq'

  # Suggestion 
  resource :suggestion, :only => [:create]
  match 'suggestion/block_db_slots' => 'suggestions#block_db_slots', via: :get
  match 'suggestion/preview' => 'suggestions#preview', via: :get

  # Token
  resources :tokens, :only => [:create, :destroy]
  match 'tokens/record' => 'tokens#record_action', via: :get
  match 'tokens/refresh/qs' => 'tokens#refresh_qs', via: :get
  match 'tokens/refresh/ws' => 'tokens#refresh_ws', via: :get
  match 'tokens/refresh/dbt' => 'tokens#refresh_dbt', via: :get
  match 'tokens/verify' => 'tokens#verify', via: :get
  match 'tokens/validate' => 'tokens#validate', via: :get
  match 'tokens/view_fdb' => 'tokens#view_fdb', via: :get
  match 'tokens/view_hints' => 'tokens#view_hints', via: :get
  match 'tokens/bill_ws' => 'tokens#bill_ws', via: :get
  match 'tokens/match' => 'tokens#match_name', via: :get
  match 'tokens/claim' => 'tokens#claim_account', via: :get
  
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
