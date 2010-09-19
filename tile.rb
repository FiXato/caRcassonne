require 'yaml'
class Tile
  attr_accessor :id, :type, :graphic, :north, :east, :south, :west, :center, :rotation, :multiplier, :graphic_packed, :gosu_image, :dimensions

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

  # Simply delegate to == in this example.
  def eql?(comparee)
    self == comparee
  end

  # Objects are equal if they have the same
  # directions
  def ==(comparee)
    self.north == comparee.north && self.east == comparee.east && self.west == comparee.west && self.south == comparee.south && self.center == comparee.center && self.multiplier == comparee.multiplier && self.type == comparee.type
  end
end
