Webapp::Application.routes.draw do
  # post "question/insert_new"

  devise_for :accounts do 
    get '/login' => 'devise/sessions#new'
    get '/logout' => 'devise/sessions#destroy'
  end 

  #get "teachers/index"
  
  # Admin 
  resource :admin, :controller => :admin 

  # Board 
  resource :board, :only => [:create, :update]
  # match 'get_course_details/:board_id' => 'boards#get_course_details', :via => :get
  match 'boards/summary' => "boards#summary", :via => :get

  # Course
  resource :course, :only => [:show, :create, :update]
  match 'courses/list' => 'courses#list', :via => :get
  match 'course/profile' => 'courses#profile', :via => :get
  match 'course/coverage' => 'courses#coverage', :via => :get

  # Examiner 
  resource :examiner, :except => [:new, :destroy]

  # Grade
  resource :grade, :only => [:update]

  # School 
  resource :school, :only => [:show, :create, :update]
  match 'school/students/add' => 'schools#add_students', :via => :post
  match 'schools/list' => 'schools#list', :via => :get 
  match 'school/unassigned-students' => 'schools#unassigned_students', :via => :get
  match 'school/sektions' => 'schools#sektions', :via => :get

  # Macro Topic
  match 'macro_topic/micros_in_course' => 'macro_topics#micros_in_course', :via => :get
  match 'macros/list' => 'macro_topics#list', :via => :get

  # Micro Topic 
  resource :micro_topic, :only => [:create, :update]
  match 'topics/list' => 'micro_topics#list', :via => :get

  # Question
  resource :question, :only => [:create, :update], :controller => :question
  match 'questions/list' => 'question#list', :via => :get
  match 'question/preview' => 'question#preview', :via => :get

  # Quiz
  resource :quiz, :only => [:show, :create]
  match 'quiz/candidate_questions' => 'quizzes#get_candidates', :via => :get
  match 'quizzes/list' => 'quizzes#list', :via => :get
  match 'quiz/preview' => 'quizzes#preview', :via => :get
  match 'quiz/assign' => 'quizzes#assign_to', :via => :put

  # Student 
  resource :student, :only => [:create, :update]

  # Study Group 
  resource :sektion, :only => [:create, :update]
  match 'sektions/list' => 'sektions#list', :via => :get
  match 'sektions/update_student_list' => 'sektions#update_student_list', :via => :put
  match 'sektions/students' => 'sektions#students', :via => :get

  # Syllabus
  resource :syllabus, :only => [:show, :update]
   
  # Teacher 
  resource :teacher, :only => [:create, :update, :show]
  match 'teachers/list' => 'teachers#list', :via => :get
  match 'teachers/roster' => 'teachers#roster', :via => :get 
  match 'teacher/update_roster' => 'teachers#update_roster', :via => :put
  match 'teacher/coverage' => 'teachers#coverage', :via => :get
  match 'teacher/load' => 'teachers#load', :via => :get

  # Yardstick
  resource :yardstick, :only => [:show, :create, :update]

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
