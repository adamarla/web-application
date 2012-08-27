
# scroll.overlayJson will use the JSON generated here. And so, the JSON must conform 
# to the layout expected by overlayJson, which is - [ { key => {parent => ..., id => [...] } } ] 

node(:insight) {
  [{ :candidates => {:parent => 0, :id => @logical.map(&:insight_id).uniq } }]
}

node(:formulation) {
  [{ :candidates => {:parent => 1, :id => @logical.map(&:formulation_id).uniq } }]
} 

node(:calculation) { 
  [{ :candidates => {:parent => 2, :id => @logical.map(&:calculation_id).uniq } }]
} 

