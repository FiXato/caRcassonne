require 'yaml'
class Road
  attr_accessor :road_number, :pawns, :tiles
  def initialize
    @@road_number_counter ||= 0
    @road_number = (@@road_number_counter += 1)
  end
end