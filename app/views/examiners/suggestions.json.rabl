
node :wips do 
  @wips.map{ |m| { :suggestion => {:id => m.id, :name => m.image,
                      :parent => m.weeks_since_receipt(true), :receipt => m.label }} }
end

node :just_in do 
  @just_in.map{ |m| { :suggestion => {:id => m.id, :name => m.image,
                      :parent => m.weeks_since_receipt(true), :receipt => m.label }} }
end

node :completed do 
  @completed.map{ |m| { :suggestion => {:id => m.id, :name => m.image,
                      :parent => m.weeks_since_receipt(true), :receipt => m.label }} }
end

node :preview do
  { :id => @all.map(&:id), :scans => @all.map{ |m| [m.image]} }
end

