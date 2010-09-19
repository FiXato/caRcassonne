require 'rubygems'
require 'gosu'
require "yaml"
class GameWindow < Gosu::Window
  attr_accessor :grid, :tile_width, :tile_height, :tile_set, :save_state_filename
  attr_reader :width, :height

  def initialize(caption="Gosu Application",width=800,height=600)
    super(width, height, false)
    @width = width
    @height = height
    self.caption = caption
    @save_state_filename = File.expand_path(File.join("savestates",Time.now.strftime("%Y%m%d%H%M%S")+".yaml"))
    @ticks = 0
  end

  def update
    @ticks += 1
    return unless @ticks % 5 == 1
    @current_tile ||= {
      :tile => tile = tile_set.get_tile,
      :image => Gosu::Image.new(self, tile.graphic, true),
      :grid_x => 0,
      :grid_y => 0,
      :x => tile_width / 2,
      :y => tile_height / 2,
    }
    if button_down? Gosu::Button::KbLeft or button_down? Gosu::Button::GpLeft then
      unless @current_tile[:grid_x] == 0
        @current_tile[:grid_x] -= 1 
        puts @current_tile[:grid_x]
      end
    end
    if button_down? Gosu::Button::KbRight or button_down? Gosu::Button::GpRight then
      unless @current_tile[:grid_x] == @grid.max_x
        @current_tile[:grid_x] += 1
        puts @current_tile[:grid_x]
      end
    end
    if button_down? Gosu::Button::KbDown or button_down? Gosu::Button::GpDown then
      unless @current_tile[:grid_y] == @grid.max_y
        @current_tile[:grid_y] += 1 
        puts @current_tile[:grid_y]
      end
    end
    if button_down? Gosu::Button::KbUp or button_down? Gosu::Button::GpUp then
      unless @current_tile[:grid_y] == 0
        @current_tile[:grid_y] -= 1
        puts @current_tile[:grid_y]
      end
    end
    if button_down? Gosu::Button::KbSpace or button_down? Gosu::Button::GpButton0 then
      @current_tile[:tile].rotate_clockwise
    end
    if button_down? Gosu::Button::KbReturn or button_down? Gosu::Button::GpButton1 then
      puts 'Trying to place tile at %sx%s' % [@current_tile[:grid_x],@current_tile[:grid_y]]
      if @grid.place_tile(@current_tile[:tile],@current_tile[:grid_x],@current_tile[:grid_y])
        @current_tile = nil
        dup_grid = @grid.dup
        dup_grid.tiles.each {|tile|tile[2].gosu_image = nil} #kill the gosu images, because they can't be imported.
        save_state = {:grid => dup_grid, :tile_set => @tile_set}
        File.open(@save_state_filename, "w") { |file| YAML.dump(save_state, file) }
        grid.draw_text
      end
    end
    if button_down? Gosu::Button::KbBackspace or button_down? Gosu::Button::GpButton2 then
      @tile_set.empty_tiles
      @current_tile = nil
    end
  rescue OutOfTilesException
    puts "No more tiles available!"
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
    grid.draw(self)
    @current_tile[:image].draw_rot(@current_tile[:grid_x] * tile_width + tile_width/2,@current_tile[:grid_y] * tile_height + tile_height/2,0,@current_tile[:tile].rotation) if @current_tile
  end
  
  def set_background(filename)
    @background_image = Gosu::Image.new(self, filename, true)
  end
end