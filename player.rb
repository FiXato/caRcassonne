require 'pawn'
class Player
  attr_accessor :name, :points, :pawns
  attr_reader :available_pawns
  def initialize(name)
    self.name = name
    self.points = 0
    self.pawns = (1..7).map{Pawn.new(name)}
    update_available_pawns
  end

  def update_available_pawns
    pawn_groups = pawns.group_by{|pawn|pawn.position}
    @available_pawns = pawn_groups.has_key?(:bag) ? pawn_groups[:bag].size : 0
  end
end