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
#    if school.nil?
#      school = School.new
#      school[:name] = studentform[:school]
#    end
#    unless school.save head(:bad_request)
      student = Student.new 
      theSchool = School.find_by_id(10)
      student.name = studentform[:name]
      student.school = theSchool
      student.klass = studentform[:gradelevel]
      password = "gradians"
      username = create_username_for student, :student
      email = studentform[:email]

      unless username.blank?
        account = student.build_account :username => username, :email => email,
                                      :password => password, :password_confirmation => password
        if student.save 
          render :json => {:status => "registered"}
          Mailbot.welcome_student(account).deliver
        else
          render :json => {:status => "Failed!"} 
        end
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

end
