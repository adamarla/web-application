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
    if studentform[:name].length == 0 or 
       studentform[:email].length == 0 or
       studentform[:school].length == 0 or
       studentform[:gradelevel].length == 0 or
       studentform[:country].length == 0

      render :json => { :status => "bad request" }
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
        render :json => {:status => "registered"}
      else
        render :json => {:status => "Failed!"} 
      end
    end
  end

  def register_teacher 

    teacherform = params[:teacherform]    
    puts teacherform[:name]
    puts teacherform[:name].length

    if teacherform[:name].length == 0 or 
       teacherform[:email].length == 0 or
       teacherform[:org].length == 0
      render :json => { :status => "bad request" }
    else
      Mailbot.curious_email(teacherform)
      render :json => { :status => "registered" } 
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
