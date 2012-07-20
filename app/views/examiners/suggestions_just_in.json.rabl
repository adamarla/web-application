
node :suggestions do 
  @pending.map{ |m| { :suggestion => {:id => m.id, :name => m.label, 
                      :parent => m.weeks_since_receipt(true), :image => m.image }} }
end

node :preview do
  { :id => @pending.map(&:id), :scans => @pending.map{ |m| [m.image]} }
end

