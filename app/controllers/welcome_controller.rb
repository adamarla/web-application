class WelcomeController < ApplicationController
  def index
    unless current_account.nil? 
      case current_account.role 
        when :examiner
          redirect_to '/examiner'
        when :admin 
          redirect_to '/admin'
        when :teacher 
          redirect_to teacher_path
        when :student 
          redirect_to student_path
      end 
    end 
  end
  
  def about_us
  
  end
  
  def how_it_works
  
  end
  
  def download
  
  end

  def countries
    @countries = Country.all
    render :json => @countries
  end

  def contactus
    contact_form = params[:contact_form]    
    Mailbot.suggestion_email(contact_form)
    render :json => { :status => "done" } 
  end

  def register_student 
    studentform = params[:studentform]
    name = studentform[:name]
    email = studentform[:email]
    school_name = studentform[:school]
    grade_level = studentform[:gradelevel].to_i
    country = studentform[:country]


    if name.length == 0  
      render :json => { :status => "error", :message => "Please enter a name" }
    elsif email.length == 0
      render :json => { :status => "error", :message => "Please provide an email" }
    elsif school_name.length == 0
      render :json => { :status => "error", :message => "Please enter a school" }
    elsif grade_level < 8 or grade_level > 12
      render :json => { :status => "error", :message => "For grades (9 - 12) only" }
    elsif country.length == 0
      render :json => { :status => "error", :message => "Please provide Country of residence" }
    else
      student = Student.new 
      student.name = studentform[:name]
      student.klass = studentform[:gradelevel].to_i
      email = studentform[:email]
      school = School.find_by_id(GRADIANS_UNIVERSITY_ID)
      password = "gradians"

      username = create_username_for student, :student
      unless username.blank?
        account = student.build_account :username => username, :email => email,
                      :password => password, :password_confirmation => password
      end

      case student.klass
        when 9
          quiz_ids = GRADE_09_SUBJECT_01
          sektion_id = GRADE_09_CURRENT_SEKTION
        when 10
          quiz_ids = GRADE_10_SUBJECT_01
          sektion_id = GRADE_10_CURRENT_SEKTION
        when 11
          quiz_ids = GRADE_11_SUBJECT_01
          sektion_id = GRADE_11_CURRENT_SEKTION
        when 12
          quiz_ids = GRADE_12_SUBJECT_01
          sektion_id = GRADE_12_CURRENT_SEKTION
      end
      sektion = Sektion.find_by_id(sektion_id)
      student.sektions << sektion
      
      if student.save
        quiz_ids.each do |quiz_id|
          publish = true
          quiz = Quiz.find_by_id(quiz_id)
          students = [student[:id]]
          Delayed::Job.enqueue BuildTestpaper.new(quiz, students, publish), :priority => 0, :run_at => Time.zone.now
        end
        Mailbot.welcome_student(account).deliver
        render :json => {:status => "registered", :message =>"You are all set #{student.first_name}. Welcome to gradians, check your email for further instruction." }
      else
        render :json => {:status => "Failed!", :message => "Oops! Glitch at our end, we'll look into it. Please come back soon!"} 
      end
    end
  end

  def register_teacher 
    teacherform = params[:teacherform]    
    name = teacherform[:name]
    email = teacherform[:email]
    org = teacherform[:org]

    if name.length == 0
      render :json => { :status => "error", :message => "Please provide your first and last names" }
    elsif email.length == 0
      render :json => { :status => "error", :message => "Please provide a working email address" }
    elsif org.length == 0
      render :json => { :status => "error", :message => "Please provide the name of your School" }
    else
      Mailbot.curious_email(teacherform)
      render :json => { :status => "registered", :message => "Got it. Thanks #{name}, you'll hear from us very shortly" } 
    end
  end

  GRADIANS_UNIVERSITY_ID = 13 

  GRADE_09_SUBJECT_01 = [266]
  GRADE_10_SUBJECT_01 = [266]
  GRADE_11_SUBJECT_01 = [267]
  GRADE_12_SUBJECT_01 = [267]

  GRADE_09_CURRENT_SEKTION = 82
  GRADE_10_CURRENT_SEKTION = 83 
  GRADE_11_CURRENT_SEKTION = 84 
  GRADE_12_CURRENT_SEKTION = 85

end
