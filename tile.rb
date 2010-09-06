require 'yaml'
class Tile
  attr_accessor :id, :type, :graphic, :north, :east, :south, :west, :center

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
    self
  end
end

class Grid
  attr_accessor :max_x, :max_y, :tiles
  #, :tile_width, :tile_height
  def initialize(starting_tile)
    self.tiles = [[4,4,starting_tile]]
  end
  
  def draw
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
end

# class TileSet
#   attr_reader :id, :name, :tiles
#   def initialize(name)
#     self.name = name
#     self.id = rand(1000)
#     tiles = YAML.load_file('%s-tiles.yaml')
#     tiles.each 
#     self.tiles = 
#   end
# end
# 
# classic = TileSet.new('classic')

monastery = Tile.new
monastery.type = :monastery
monastery.graphic = {
  :image  => 'carc-tiles-main.jpg',
  :x      => 0,
  :y      => 0,
  :width  => 85,
  :height => 85,
}
monastery.north,monastery.south,monastery.east,monastery.west = [:meadow]
monastery.center = :monastery

monastery_with_road = Tile.new
monastery_with_road.type = :monastery
monastery_with_road.graphic = {
  :image  => 'carc-tiles-main.jpg',
  :x      => 100,
  :y      => 0,
  :width  => 85,
  :height => 85,
}
monastery_with_road.north,monastery_with_road.east,monastery_with_road.west = [:meadow]
monastery_with_road.south = [:meadow, :road]
monastery_with_road.center = :monastery

starting_tile = Tile.new
starting_tile.type = :starting_tile
starting_tile.graphic = {
  :image  => 'carc-tiles-main.jpg',
  :x      => 400,
  :y      => 400,
  :width  => 85,
  :height => 85,
}
starting_tile.north = [:city]
starting_tile.east = [:meadow,:road]
starting_tile.south = [:meadow]
starting_tile.west = [:meadow,:road]
starting_tile.center = :road

grid = Grid.new(starting_tile)
grid.max_y = 10
grid.max_x = 10
puts "defined grid as #{grid.max_x} by #{grid.max_y}"
rotated_monastery_with_road = monastery_with_road.rotate_clockwise
puts rotated_monastery_with_road.to_yaml
puts grid.place_tile(rotated_monastery_with_road,5,4)
puts grid.place_tile(monastery_with_road,0,2)
puts grid.place_tile(monastery_with_road,0,2)
puts grid.place_tile(monastery_with_road,2,2)
puts grid.place_tile(monastery_with_road,3,2)
puts grid.place_tile(monastery_with_road,2,3)
grid.draw
while (input = gets.chomp) != ''
  x,y = input.split(',')
  grid.place_tile(monastery_with_road,x.to_i,y.to_i)
  grid.draw
end