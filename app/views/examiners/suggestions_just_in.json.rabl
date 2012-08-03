
node :suggestions do 
  @pending.map{ |m| { :suggestion => {:id => m.id, :name => m.image, 
                      :parent => m.weeks_since_receipt(true), :receipt => m.label }} }
end

node :preview do
  { :id => @pending.map(&:id), :scans => @pending.map{ |m| [m.image]} }
end

