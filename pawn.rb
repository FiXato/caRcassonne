class Pawn
  attr_accessor :position, :grid_position, :sub_grid_position, :player_name, :image
  def initialize(player_name)
    self.position = :bag
    self.grid_position = {:x => 0, :y => 0}
    self.sub_grid_position = {:x => 0, :y => 0}
    self.player_name = player_name
  end
end