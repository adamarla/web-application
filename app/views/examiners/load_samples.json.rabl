
object false 
  node(:tabs){
    @gids.map{ |g| { name: "##{@gids.index(g) + 1}", id: g } } 
  }
  node(:user) { 'Examiner' }
  node(:sandbox) { true }
  node(:apprentice) { @apprentice }
