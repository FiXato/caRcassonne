require 'rubygems'
require 'gosu'
require 'rubygems'
require 'tile'
require 'tile_set'
require 'grid'
require "yaml"
class TileEditor < Gosu::Window
  attr_accessor :grid, :tile_width, :tile_height, :tile_set
  attr_reader :width, :height

  def initialize(caption="Tile Editor",width=800,height=600)
    super(width, height, false)
    @width = width
    @height = height
    self.caption = caption
    @ticks = 0
  end

  def update
    @ticks += 1
    return unless @ticks % 5 == 1
    @current_tile ||= {
      :grid_x => 0,
      :grid_y => 0,
      :x => tile_width / 2,
      :y => tile_height / 2,
      :image => Gosu::Image.new(self, File.expand_path("resources/tiles/Carcassonne Classic[16 colours]/Outline.png"), true)
    }
    @selected_tile = nil
    if button_down? Gosu::Button::KbLeft or button_down? Gosu::Button::GpLeft then
      unless @current_tile[:grid_x] == 0
        @current_tile[:grid_x] -= 1 
      end
    end
    if button_down? Gosu::Button::KbRight or button_down? Gosu::Button::GpRight then
      unless @current_tile[:grid_x] == @grid.max_x - 1
        @current_tile[:grid_x] += 1
      end
    end
    if button_down? Gosu::Button::KbDown or button_down? Gosu::Button::GpDown then
      unless @current_tile[:grid_y] == @grid.max_y - 1
        @current_tile[:grid_y] += 1 
      end
    end
    if button_down? Gosu::Button::KbUp or button_down? Gosu::Button::GpUp then
      unless @current_tile[:grid_y] == 0
        @current_tile[:grid_y] -= 1
      end
    end
    # if button_down? Gosu::Button::KbSpace or button_down? Gosu::Button::GpButton0 then
    #   @current_tile[:tile].rotate_clockwise
    # end
    if button_down? Gosu::Button::KbReturn or button_down? Gosu::Button::GpButton1 then
      puts 'Trying to select tile at %sx%s' % [@current_tile[:grid_x],@current_tile[:grid_y]]
      if @grid.has_tile?(@current_tile[:grid_x],@current_tile[:grid_y])
        @selected_tile = @grid.tile(@current_tile[:grid_x],@current_tile[:grid_y])
      end
    end
    if button_down? Gosu::Button::KbBackspace or button_down? Gosu::Button::GpButton2 then
      @tile_set.empty_tiles
      @current_tile = nil
    end
  rescue OutOfTilesException
    @current_tile = nil
  end

  def draw
    if @background_image
      (0..(@width/tile_width)).each do |x_index|
        offset_x = x_index * tile_width
        (0..(@height/tile_height)).each do |y_index|
          offset_y = y_index * tile_height
          @background_image.draw(offset_x - 1, offset_y - 1, 0)
        end
      end
    end
    @grid.draw(self) if @grid
    @current_tile[:image].draw(@current_tile[:grid_x] * tile_width,@current_tile[:grid_y] * tile_height,0) if @current_tile
  end
  
  def set_background(filename)
    @background_image = Gosu::Image.new(self, filename, true)
  end
end