
node :suggestions do 
  @items.map{ |m| { :suggestion => {:id => m.id, :name => m.image,
                      :parent => m.weeks_since_receipt(true), :receipt => m.label }} }
end

node :preview do
  { :id => @items.map(&:id), :scans => @items.map{ |m| [m.image]} }
end

