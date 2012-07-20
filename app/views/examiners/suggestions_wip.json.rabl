
node :suggestions do 
  @wip.map{ |m| { :suggestion => {:id => m.id, :name => m.label, 
                      :parent => m.weeks_since_receipt(true), :image => m.image }} }
end

node :preview do
  { :id => @wip.map(&:id), :scans => @wip.map{ |m| [m.image]} }
end

