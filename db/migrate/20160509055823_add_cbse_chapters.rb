class AddCbseChapters < ActiveRecord::Migration
  def up
    chapters = [
                  "sets",
                  "relations and functions", 
                  "trigonometric functions", 
                  "mathematical induction", 
                  "complex numbers", 
                  "linear inequalities", 
                  "permutations and combinations", 
                  "binomial theorem", 
                  "sequences and series", 
                  "straight lines", 
                  "conic sections", 
                  "introductory 3D geometry",
                  "limits and derivatives", 
                  "mathematical reasoning", 
                  "statistics", 
                  "probability-1",
                  "inverse trigonometric functions", 
                  "matrices", 
                  "determinants", 
                  "continuity and differentiability", 
                  "application of derivatives", 
                  "integrals", 
                  "application of integrals", 
                  "differential equations", 
                  "vector algebra",
                  "linear programming",
                  "probability-2"
               ]

     chapters.each do |name| 
        c = Chapter.quick_add name 
        Parcel.for_chapter(c.id) unless c.id.nil?
     end 

     # And a Generic Chapter with just one parcel for Skills 
     c = Chapter.quick_add "generic" 
     Parcel.create(chapter_id: c.id, contains: Skill.name) unless c.id.nil?

  end

  def down
  end
end
