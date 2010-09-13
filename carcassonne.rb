#!/usr/bin/env ruby
require 'rubygems'
require 'tile'
require 'tile_set'
require 'grid'
require 'game_window'
@savestate = YAML.load_file(ARGV.shift) if ARGV.size > 0
@window = GameWindow.new("caRcassonne",800,800)
@window.set_background("tilesets/background.png")
if @savestate
  @window.tile_set = @savestate[:tile_set]
else
  @window.tile_set = TileSet.load('Carcassonne-Classic')
end
@window.tile_width = @window.tile_set.tile_dimensions[0]
@window.tile_height = @window.tile_set.tile_dimensions[1]

if @savestate
  @window.grid = @savestate[:grid]
else
  @window.grid = Grid.new
  @window.grid.max_x = @window.width / @window.tile_width
  @window.grid.max_y = @window.height / @window.tile_height
  puts "defined grid as #{@window.grid.max_x} by #{@window.grid.max_y}"
  @window.grid.starting_tile = @window.tile_set.get_tile
  @window.grid.place_starting_tile
  puts @window.grid.to_yaml
end
@window.show
