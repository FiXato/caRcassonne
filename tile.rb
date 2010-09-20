require 'yaml'
class Array
  def road?
    self.include?(:road)
  end

  def city?
    self.include?(:city)
  end

  def meadow?
    self.include?(:meadow)
  end
end
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

  def to_graphs
    grass = '·'
    city = '#'
    monastery = '⌂'
    graph = []
    if self.north.road?
      graph << [grass,'║',grass]
    elsif self.north == [:city]
      graph << [city,city,city]
    else
      graph << [grass,grass,grass]
    end

    middle_graph = []
    if self.west == [:city]
      middle_graph << city
    elsif self.west.road?
      middle_graph << '═'
    else
      middle_graph << grass
    end

    if self.center == :monastery
      middle_graph << monastery
    elsif self.center == :city
        middle_graph << city

    #Four road exits
    elsif self.north.road? && self.west.road? && self.south.road? && self.east.road?
      middle_graph << '╬'

    #Three road exits
    elsif self.north.road? && self.west.road? && self.south.road? && !self.east.road?
      middle_graph << '╣'
    elsif self.north.road? && self.west.road? && !self.south.road? && self.east.road?
      middle_graph << '╩'
    elsif self.north.road? && !self.west.road? && self.south.road? && self.east.road?
      middle_graph << '╠'
    elsif !self.north.road? && self.west.road? && self.south.road? && self.east.road?
      middle_graph << '╦'


    #Two road exits
    elsif self.north.road? && self.west.road? && !self.south.road? && !self.east.road?
      middle_graph << '╝'
    elsif self.north.road? && !self.west.road? && !self.south.road? && self.east.road?
      middle_graph << '╚'
    elsif !self.north.road? && !self.west.road? && self.south.road? && self.east.road?
      middle_graph << '╔'
    elsif !self.north.road? && self.west.road? && self.south.road? && !self.east.road?
      middle_graph << '╗'
    elsif self.north.road? && !self.west.road? && self.south.road? && !self.east.road?
      middle_graph << '║'
    elsif !self.north.road? && self.west.road? && !self.south.road? && self.east.road?
      middle_graph << '═'
    else
      middle_graph << grass
    end

    if self.east == [:city]
      middle_graph << city
    elsif self.east.road?
      middle_graph << '═'
    else
      middle_graph << grass
    end
    graph << middle_graph

    if self.south == [:meadow, :road]
      graph << [grass,'║',grass]
    elsif self.south == [:city]
      graph << [city,city,city]
    else
      graph << [grass,grass,grass]
    end
    graph
  end

  def draw_graphs
    self.to_graphs.each{|graph_line|puts graph_line.join('')}
  end
end
