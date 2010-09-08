require 'rubygems'
require 'gosu'
require 'tile.rb'
class GameWindow < Gosu::Window
  def initialize
    super(550, 600, false)
    self.caption = "Gosu Tutorial Game"
    
    @background_image = Gosu::Image.new(self, "carc-tiles-main.png", true)
    monastery = Tile.new
    monastery.type = :monastery
    monastery.graphic = {
      :image  => 'monastery.png',
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
      :image  => 'monastery_with_road.png',
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
      :image  => 'starting_tile.png',
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
    
    @grid = Grid.new(starting_tile)
    @grid.max_y = 10
    @grid.max_x = 10
    puts "defined grid as #{@grid.max_x} by #{@grid.max_y}"
    rotated_monastery_with_road = monastery_with_road.dup.rotate_clockwise
    puts @grid.place_tile(rotated_monastery_with_road,5,4)
    puts @grid.place_tile(monastery,5,3)
    puts @grid.place_tile(monastery_with_road,6,3)
    puts @grid.place_tile(monastery_with_road,0,2)
    puts @grid.place_tile(monastery_with_road,0,2)
    puts @grid.place_tile(monastery_with_road,2,2)
    puts @grid.place_tile(monastery_with_road,3,2)
    puts @grid.place_tile(monastery_with_road,2,3)
    # grid.draw
    # while (input = gets.chomp) != ''
    #   x,y = input.split(',')
    #   grid.place_tile(monastery_with_road,x.to_i,y.to_i)
    #   grid.draw
    # end
  end

  def update
  end

  def draw
    # @background_image.draw(0, 0, 0);
    @grid.draw(self)
  end
end
@window = GameWindow.new
@window.show