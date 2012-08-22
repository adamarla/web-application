
collection @grades => :grades 
  attribute :calibration_id
  node(:marks) { |m| (m.allotment/25).round(2) } # 1/25 = 4/100
