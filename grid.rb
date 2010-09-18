require 'yaml'
require 'tile'
class Grid
  attr_accessor :max_x, :max_y, :tiles, :tile_images, :starting_tile
  #, :tile_width, :tile_height
  def initialize
    self.tiles = []
    self.tile_images = []
    self.max_x = 10
    self.max_y = 10
  end
  
  def draw_text
    print '    '
    (0..max_x).each do |x|
      print '%i ' % x
    end
    puts
    puts '   %s' % ('-' * (max_x * 2 + 3))
    (0..max_y).each do |y|
      letter = (y + 10)
      print '%s | ' % letter.to_s(26)
      (0..max_x).each do |x|
        print '%s ' % tile_graphic(x,y)
      end
      puts 
    end
  end

  def place_starting_tile
    place_tile(starting_tile,max_x/2,max_y/2) if starting_tile
  end

  def place_tile(tile,x,y,force=false)
    if force
      self.tiles << [x,y,tile]
      return true
    end
    return false if has_tile?(x,y)
    #check north:
    unless tiles_compatible?(tile,north_tile = self.tile(x,y-1),:north)
      puts "north incompatible"
      return false
    end
    #check south:
    unless tiles_compatible?(tile,south_tile = self.tile(x,y+1),:south)
      puts "south incompatible"
      return false
    end
    #check east:
    unless tiles_compatible?(tile,east_tile = self.tile(x+1,y),:east)
      puts "east incompatible"
      return false
    end
    #check west:
    unless tiles_compatible?(tile,west_tile = self.tile(x-1,y),:west)
      puts "west incompatible"
      return false
    end
    if tiles.size > 0 && [north_tile,south_tile,east_tile,west_tile].compact == [] #has to be attached to at least 1 tile
      puts "No tile to connect to"
      return false
    end
    self.tiles << [x,y,tile]
    return true
  end

  def tiles_compatible?(tile_a,tile_b, orientation)
    return true if tile_b.nil?
    case orientation
    when :north
      puts "#{tile_a.north} == #{tile_b.south}"
      tile_a.north == tile_b.south
    when :south
      puts "#{tile_a.south} == #{tile_b.north}"
      tile_a.south == tile_b.north
    when :east
      puts "#{tile_a.east} == #{tile_b.west}"
      tile_a.east == tile_b.west
    when :west
      puts "#{tile_a.west} == #{tile_b.east}"
      tile_a.west == tile_b.east
    end
  end

  def has_tile?(x,y)
    return false if tiles == []
    tiles.find{|tile| tile[0] == x && tile[1] == y}
  end

  def tile(x,y)
    puts "requesting tile at #{x},#{y}"
    tile = tiles.find{|tile| tile[0] == x && tile[1] == y}
    puts "Tile found: #{tile.to_yaml}" unless tile.nil?
    return nil if tile.nil?
    return tile[2]
  end

  def tile_graphic(x,y)
    has_tile?(x,y) ? 'x' : '-'
  end
  
  def draw(window)
    tiles.each do |tile|
      unless tile[2].gosu_image
        tile[2].gosu_image = Gosu::Image.new(window, tile[2].graphic, false)
      end
      tile[2].gosu_image.draw_rot(tile[0] * window.tile_width + window.tile_width / 2,tile[1] * window.tile_height + window.tile_height / 2,0,tile[2].rotation)
    end
  end
end