
object false

node(:topics) {
  @topics.map { |m| {:topic => {:id => m.id, :name => m.name }} }
}

node(:vertical) { @vertical_id }
