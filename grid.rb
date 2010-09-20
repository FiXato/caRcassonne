require 'yaml'
require 'tile'
class Array
  def road?
    self.include?(:road)
  end
end
class Grid
  attr_accessor :max_x, :max_y, :tiles, :tile_images, :starting_tile, :offset
  #, :tile_width, :tile_height
  def initialize
    self.tiles = []
    self.tile_images = []
    self.max_x = 10
    self.max_y = 10
    self.offset = {:x => 0, :y => 0}
  end
  
  def draw_text
    print ' ' * 3
    (0..max_x).each do |x|
      print ' %s ' % x.to_s(26)
    end
    print "\n"
    (0..max_y).each do |y|
      #get all graphics for this row
      graphs = (0..max_x).map do |x|
        tile_graphic(x,y)
      end
      #Print all graphs line by line.
      (0..2).each do |graph_line|
        print (graph_line == 1 ? y : ' ')
        print ' ' * 2
        graphs.each do |graph|
          print graph[graph_line]
        end
        print "\n"
      end
    end
  end

  def place_starting_tile
    place_tile!(starting_tile,max_x/2,max_y/2) if starting_tile
  end

  # Place tile without checking if it is a valid tile position
  def place_tile!(tile,x,y)
    self.tiles << [x,y,tile]
  end

  # Check if the tile is in a valid tile position, a.k.a. placeable, and then place it
  # Returns true on success and false upon failure
  def place_tile(tile,x,y)
    return false if x > max_x || y > max_y
    return false if has_tile?(x,y)
    #check north:
    unless tiles_compatible?(tile,north_tile = self.tile(x,y-1),:north)
      # puts "north incompatible"
      return false
    end
    #check south:
    unless tiles_compatible?(tile,south_tile = self.tile(x,y+1),:south)
      # puts "south incompatible"
      return false
    end
    #check east:
    unless tiles_compatible?(tile,east_tile = self.tile(x+1,y),:east)
      # puts "east incompatible"
      return false
    end
    #check west:
    unless tiles_compatible?(tile,west_tile = self.tile(x-1,y),:west)
      # puts "west incompatible"
      return false
    end
    if [north_tile,south_tile,east_tile,west_tile].compact == [] #has to be attached to at least 1 tile
      # puts "No tile to connect to"
      return false
    end
    place_tile!(tile,x,y)
    return true
  end

  def tiles_compatible?(tile_a,tile_b, orientation)
    return true if tile_b.nil?
    case orientation
    when :north
      # puts "#{tile_a.north} == #{tile_b.south}"
      tile_a.north == tile_b.south
    when :south
      # puts "#{tile_a.south} == #{tile_b.north}"
      tile_a.south == tile_b.north
    when :east
      # puts "#{tile_a.east} == #{tile_b.west}"
      tile_a.east == tile_b.west
    when :west
      # puts "#{tile_a.west} == #{tile_b.east}"
      tile_a.west == tile_b.east
    end
  end

  def has_tile?(x,y)
    return false if tiles == []
    tiles.find{|tile| tile[0] == x && tile[1] == y}
  end

  def tile(x,y)
    # puts "requesting tile at #{x},#{y}"
    tile = tiles.find{|tile| tile[0] == x && tile[1] == y}
    # puts "Tile found: #{tile.to_yaml}" unless tile.nil?
    return nil if tile.nil?
    return tile[2]
  end

  def tile_graphic(x,y)
    grass = '.'
    city = '#'
    monastery = '⌂'
    empty = ' '
    unless tile = tile(x,y)
      return [[empty, empty, empty],[empty, empty, empty],[empty, empty, empty]]
    end
    graph = []
    if tile.north.road?
      graph << [grass,'║',grass]
    elsif tile.north == [:city]
      graph << [city,city,city]
    else
      graph << [grass,grass,grass]
    end

    middle_graph = []
    if tile.west == [:city]
      middle_graph << city
    elsif tile.west.road?
      middle_graph << '═'
    else
      middle_graph << grass
    end

    if tile.center == :monastery
      middle_graph << monastery
    elsif tile.center == :city
        middle_graph << city

    #Four road exits
    elsif tile.north.road? && tile.west.road? && tile.south.road? && tile.east.road?
      middle_graph << '╬'

    #Three road exits
    elsif tile.north.road? && tile.west.road? && tile.south.road? && !tile.east.road?
      middle_graph << '╣'
    elsif tile.north.road? && tile.west.road? && !tile.south.road? && tile.east.road?
      middle_graph << '╩'
    elsif tile.north.road? && !tile.west.road? && tile.south.road? && tile.east.road?
      middle_graph << '╠'
    elsif !tile.north.road? && tile.west.road? && tile.south.road? && tile.east.road?
      middle_graph << '╦'


    #Two road exits
    elsif tile.north.road? && tile.west.road? && !tile.south.road? && !tile.east.road?
      middle_graph << '╝'
    elsif tile.north.road? && !tile.west.road? && !tile.south.road? && tile.east.road?
      middle_graph << '╚'
    elsif !tile.north.road? && !tile.west.road? && tile.south.road? && tile.east.road?
      middle_graph << '╔'
    elsif !tile.north.road? && tile.west.road? && tile.south.road? && !tile.east.road?
      middle_graph << '╗'
    elsif tile.north.road? && !tile.west.road? && tile.south.road? && !tile.east.road?
      middle_graph << '║'
    elsif !tile.north.road? && tile.west.road? && !tile.south.road? && tile.east.road?
      middle_graph << '═'
    else
      middle_graph << grass
    end

    if tile.east == [:city]
      middle_graph << city
    elsif tile.east.road?
      middle_graph << '═'
    else
      middle_graph << grass
    end
    graph << middle_graph

    if tile.south == [:meadow, :road]
      graph << [grass,'║',grass]
    elsif tile.south == [:city]
      graph << [city,city,city]
    else
      graph << [grass,grass,grass]
    end
    graph
  end
  
  def draw(window)
    tiles.each do |tile|
      unless tile[2].gosu_image
        tile[2].gosu_image = Gosu::Image.new(window, tile[2].graphic, false)
      end
      x = tile[0] * window.tile_width + window.tile_width / 2
      x += offset[:x]
      y = tile[1] * window.tile_height + window.tile_height / 2
      y += offset[:y]
      tile[2].gosu_image.draw_rot(x,y,0,tile[2].rotation)
    end
  end
end