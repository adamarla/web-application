
object false 
  node(:preview) { { source: :vault,  images: @imgs } }
  node(:captions) { tmp = [*1...@imgs.count].map{ |j| "##{j}" } ; tmp.prepend('Read carefully !') }
  # @imgs comes prepended with path to standard homework instructions
