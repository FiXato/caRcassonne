require 'pawn'
class Player
  attr_accessor :name, :points, :pawns
  attr_reader :available_pawns, :placed_pawns
  def initialize(name)
    self.name = name
    self.points = 0
    self.pawns = (1..7).map{Pawn.new(name)}
    update_available_pawns
  end

  def update_available_pawns
    @placed_pawns = pawns.select{|pawn|pawn.position == :board}
    @available_pawns = pawns.select{|pawn|pawn.position == :bag}
  end

  def has_available_pawn?
    available_pawns.size > 0
  end

  def get_available_pawn
    return nil unless has_available_pawn?
    available_pawns.first
  end
end