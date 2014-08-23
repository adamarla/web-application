
window.puzzle = { 
  source : null, 
  target : null, 

  render : (json) -> # on main-page or in student console 
    return false unless json? 
    return false unless json.puzzle? 
    tex = json.puzzle.text
    return true

  preview : () -> # only Admins 
    return true
} 
