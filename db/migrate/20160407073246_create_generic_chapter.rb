class CreateGenericChapter < ActiveRecord::Migration
  def up
    generic_chapter = Chapter.quick_add "Generic"
    Parcel.create(chapter_id: generic_chapter.id, contains: Skill.name)
  end

  def down
  end
end
