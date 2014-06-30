
object false 
  node(:preview) { { source: :vault,  images: @imgs } }
  node(:captions) { [*1..@imgs.count].map{ |j| "##{j}" } }
