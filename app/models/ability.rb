class Ability
  include CanCan::Ability

  def initialize(account)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
    case account.role 
      when :student 
        can :read, Tryout, :student_id => account.loggable_id
      when :teacher 
        can [:create, :read], Quiz # let the teacher view quizzes by other teachers? 
        cannot [:update, :destroy], Quiz
      when :guardian 
      when :admin 
        can :manage, :all 
      when :school
      when :examiner
        can :manage, Tryout, :examiner_id => account.loggable_id
        cannot :destroy, Tryout
    end 
  end
end
