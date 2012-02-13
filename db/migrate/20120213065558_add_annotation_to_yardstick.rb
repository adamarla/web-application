class AddAnnotationToYardstick < ActiveRecord::Migration
  def change
    add_column :yardsticks, :annotation, :string
  end
end
