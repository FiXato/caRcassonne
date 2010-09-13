require 'yaml'
class Tile
  attr_accessor :id, :type, :graphic, :north, :east, :south, :west, :center, :rotation, :multiplier, :graphic_packed, :gosu_image

  def initialize(type=nil,graphic=nil)
    self.type = type
    self.graphic = graphic
    self.rotation = 0.0
    self.multiplier = 1
  end

  def rotate_clockwise
    new_directions = {
      :north => self.west,
      :east => self.north,
      :south => self.east,
      :west => self.south,
    }
    [:north,:east,:south,:west].each do |direction|
      self.send('%s=' % direction,new_directions[direction])
    end
    self.rotation += 90
    self
  end
end
