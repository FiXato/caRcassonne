# encoding: utf-8
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
  attr_accessor :north, :east, :south, :west, :center,
  :id, 
  :type, 
  :graphic, :graphic_packed, :gosu_image, 
  :rotation, :multiplier, 
  :dimensions, 
  :pawn, :sub_grid

  def initialize(type=nil,graphic=nil)
    self.type = type
    self.graphic = graphic
    self.rotation = 0.0
    self.multiplier = 1
    @sub_grid = [
      [[],[],[]],
      [[],[],[]],
      [[],[],[]]
    ]
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
    self.sub_grid = sub_grid.reverse.transpose
    self.rotation += 90
    self
  end

  # Simply delegate to == in this example.
  def eql?(comparee)
    self == comparee
  end

  # Objects are equal if they have the same properties
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

  def roads
    [:north,:east,:south,:west].map{|dir|dir if self.send(dir).road?}.compact
  end

  def cities
    [:north,:east,:south,:west].map{|dir|dir if self.send(dir).city?}.compact
  end

  def meadows
    [:north,:east,:south,:west].map{|dir|dir if self.send(dir).meadow?}.compact
  end

  def guess_sub_grid
    @sub_grid = [
      [[],[],[]],
      [[],[],[]],
      [[],[],[]]
    ]
    @sub_grid[0] = [:city,:city,:city] if north.city?
    @sub_grid[0] = [:meadow,:road,:meadow] if north == [:meadow,:road]
    @sub_grid[0] = [:meadow,:meadow,:meadow] if north == [:meadow]

    @sub_grid[1][0] = :road if west.road?
    @sub_grid[1][0] = :city if west.city?
    @sub_grid[1][0] = :meadow if west == [:meadow]
    if center.nil? 
      if (west.road? || east.road? || north.road? || south.road?)
        @sub_grid[1][1] = :road
      else
        @sub_grid[1][1] = :meadow
      end
    elsif center.kind_of?(Array)
      @sub_grid[1][1] = center[0]
    else
      @sub_grid[1][1] = center
    end
    @sub_grid[1][2] = :road if east.road?
    @sub_grid[1][2] = :city if east.city?
    @sub_grid[1][2] = :meadow if east == [:meadow]

    @sub_grid[2] = [:city,:city,:city] if south.city?
    @sub_grid[2] = [:meadow,:road,:meadow] if south == [:meadow,:road]
    @sub_grid[2] = [:meadow,:meadow,:meadow] if south == [:meadow]
    @sub_grid
  end
end
