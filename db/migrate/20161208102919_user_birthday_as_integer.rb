class UserBirthdayAsInteger < ActiveRecord::Migration
  def up
    add_column :users, :ibday, :integer, default: 0

    #  birthday (string) -> ibday (integer) 
    User.where('birthday IS NOT NULL').each do |u| 
      d = u.birthday.to_date.to_s.gsub('-','').to_i
      u.update_attribute :ibday, d 
    end 

    remove_column :users, :birthday
    rename_column :users, :ibday, :birthday
  end

  def down
    rename_column :users, :birthday, :ibday 
    add_column :users, :birthday, :string, limit: 50
    # ibday (integer) -> birthday (string) 

    User.where('ibday > ?', 0).each do |u| 
      d = u.ibday.to_s.to_date.strftime("%b %d, %Y")
      u.update_attribute :birthday, d
    end 

    remove_column :users, :ibday
  end
end
