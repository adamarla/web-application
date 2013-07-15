class VaultReorg < ActiveRecord::Migration
  def up
    for m in Question.all
      n = m.uid.split('-').map(&:reverse).join('/')
      m.update_attribute :uid, n
    end
  end

  def down
    for m in Question.all
      n = m.uid.split('/').map(&:reverse).join('-')
      m.update_attribute :uid, n
    end
  end
end
