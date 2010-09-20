class Pawn
  attr_accessor :position, :grid_position, :player_name
  def initialize(player_name)
    self.position = :bag
    self.grid_position = {:x => nil, :y => nil}
    self.player_name = player_name
  end
end