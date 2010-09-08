require 'yaml'
require 'tile'
class Grid
  attr_accessor :max_x, :max_y, :tiles, :tile_images
  #, :tile_width, :tile_height
  def initialize(starting_tile)
    self.tiles = [[4,4,starting_tile]]
    self.tile_images = []
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

  def place_tile(tile,x,y)
    return false if has_tile?(x,y)
    #check north:
    return false unless tiles_compatible?(tile,north_tile = self.tile(x,y-1),:north)
    #check south:
    return false unless tiles_compatible?(tile,south_tile = self.tile(x,y+1),:south)
    #check east:
    return false unless tiles_compatible?(tile,east_tile = self.tile(x+1,y),:east)
    #check west:
    return false unless tiles_compatible?(tile,west_tile = self.tile(x-1,y),:west)
    return false if [north_tile,south_tile,east_tile,west_tile].compact == [] #has to be attached to at least 1 tile
    self.tiles << [x,y,tile]
    return true
  end

  def tiles_compatible?(tile_a,tile_b, orientation)
    return true if tile_b.nil?
    case orientation
    when :north
      tile_a.north == tile_b.south
    when :south
      tile_a.south == tile_b.north
    when :east
      tile_a.east == tile_b.west
    when :west
      tile_a.west == tile_b.east
    end
  end

  def has_tile?(x,y)
    return false if tiles == []
    tiles.find{|tile| tile[0] == x && tile[1] == y}
  end

  def tile(x,y)
    tile = tiles.find{|tile| tile[0] == x && tile[1] == y}
    return nil if tile.nil?
    return tile[2]
  end

  def tile_graphic(x,y)
    has_tile?(x,y) ? 'x' : '-'
  end
  
  def draw(window)
    tiles.each do |tile|
      Gosu::Image.new(window, tile[2].graphic[:image], false).draw_rot(tile[0] * 85,tile[1] * 85,0,tile[2].rotation)
    end
  end
end