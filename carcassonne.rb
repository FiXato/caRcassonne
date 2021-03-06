#!/usr/bin/env ruby
# encoding: utf-8
unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))
  $LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
end
require 'rubygems'
require 'tile'
require 'tile_set'
require 'grid'
require 'game_window'

if ARGV.size > 0
  tileset_name = ARGV.shift
else
  tileset_name = 'Carcassonne-Classic'
end

@savestate = YAML.load_file(ARGV.shift) if ARGV.size > 0

print "Enter number of players: "
players = []
nr_of_players = gets.chomp.to_i
nr_of_players.times do
  print "Player #{players.size + 1}: "
  players << gets.chomp
end

@window = GameWindow.new("caRcassonne",800,800)

@window.set_background("resources/backgrounds/grey_outline.png")
if @savestate
  @window.tile_set = @savestate[:tile_set]
else
  @window.tile_set = TileSet.load(tileset_name)
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
@window.grid.draw_text
players.each do |name|
  @window.add_player(name)
end
@window.show
