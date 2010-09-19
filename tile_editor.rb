require 'rubygems'
require 'tile'
require 'tile_set'
require 'grid'
require 'gosu'
require "gglib"
require "ext/widgets"
require "ext/themes"
require "yaml"
class TileEditor < GGLib::GUIWindow
  attr_accessor :grid, :tile_width, :tile_height, :tile_set, :tile_set_name, :board_max_tiles_x, :board_max_tiles_y, :ticks
  attr_reader :width, :height

  def initialize(caption="Tile Editor",config={})
    config.keys.each do |k|
      self.send("#{k}=",config[k]) if self.methods.include?("#{k}=")
    end
    tile_set = TileSet.load(tile_set_name)
    self.tile_set = tile_set
    self.tile_width = tile_set.tile_dimensions[0]
    self.tile_height = tile_set.tile_dimensions[1]

    @ticks = 0
    tile_set.uniq_shuffled_tiles!
    self.grid = Grid.new
    self.grid.max_x = board_width / tile_width
    self.grid.max_y = board_height / tile_height

    super(board_width + (5*tile_width), board_height + tile_height, false)
    self.caption = caption
    self.state = TileEditorStateObj.new
    self.add_all_tiles_to_grid
  end

  def board_width
    board_max_tiles_x * tile_width
  end

  def board_height
    board_max_tiles_y * tile_height
  end

  def add_all_tiles_to_grid
    cur_x = 0
    cur_y = 0
    tile_set.shuffled_tiles.sort_by{|tile|tile.graphic}.each do |tile|
      grid.place_tile(tile,cur_x,cur_y,true)
      cur_x += 1
      if cur_x > (grid.max_x-1)
        cur_x = 0
        cur_y += 1
      end
    end
  rescue OutOfTilesException
  end
end
class TileEditorStateObj < GGLib::StateObject
  attr_accessor :grid, :tile_set, :tile_width, :tile_height
  def initialize
    @grid = $window.grid
    @tile_set = $window.tile_set
    @tile_width = $window.tile_width
    @tile_height = $window.tile_height
    super
  end

  def update
    $window.ticks += 1
    return unless $window.ticks % 5 == 1
    @current_tile ||= {
      :grid_x => 0,
      :grid_y => 0,
      :x => $window.tile_width / 2,
      :y => $window.tile_height / 2,
      :image => Gosu::Image.new($window, File.expand_path("resources/tiles/Carcassonne Classic[16 colours]/Outline.png"), true)
    }
    @selected_tile = nil
  rescue OutOfTilesException
    @current_tile = nil
  end

  def button_down(id)
    case id
    when Gosu::Button::KbLeft, Gosu::Button::GpLeft
      unless @current_tile[:grid_x] == 0
        @current_tile[:grid_x] -= 1 
      end
    when Gosu::Button::KbRight, Gosu::Button::GpRight
      unless @current_tile[:grid_x] == @grid.max_x - 1
        @current_tile[:grid_x] += 1
      end
    when Gosu::Button::KbDown, Gosu::Button::GpDown
      unless @current_tile[:grid_y] == @grid.max_y - 1
        @current_tile[:grid_y] += 1 
      end
    when Gosu::Button::KbUp, Gosu::Button::GpUp
      unless @current_tile[:grid_y] == 0
        @current_tile[:grid_y] -= 1
      end
    when Gosu::Button::KbReturn, Gosu::Button::GpButton1
      puts 'Trying to select tile at %sx%s' % [@current_tile[:grid_x],@current_tile[:grid_y]]
      if @grid.has_tile?(@current_tile[:grid_x],@current_tile[:grid_y])
        @selected_tile = @grid.tile(@current_tile[:grid_x],@current_tile[:grid_y])
        $txt_north.text = @selected_tile.north.join(", ") if @selected_tile.kind_of?(Tile)
        $txt_south.text = @selected_tile.south.join(", ") if @selected_tile.kind_of?(Tile)
        $txt_west.text = @selected_tile.west.join(", ") if @selected_tile.kind_of?(Tile)
        $txt_east.text = @selected_tile.east.join(", ") if @selected_tile.kind_of?(Tile)
        $txt_center.text = @selected_tile.center.to_s if @selected_tile.kind_of?(Tile)
      end
    end
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
    @grid.draw($window) if @grid
    @current_tile[:image].draw(@current_tile[:grid_x] * tile_width,@current_tile[:grid_y] * tile_height,0) if @current_tile
  end

  def set_background(filename)
    @background_image = Gosu::Image.new(self, filename, true)
  end

  def onStart
    puts "TileEditorStateObj activated."
    $window.setBackground("resources/backgrounds/grey_outline.png")
    $txt_tileset_name = GGLib::TextBox.new("TileSetName", $window.board_width, 0, 100, GGLib::Themes::Shade,300,50)
    $txt_tileset_name.text = $window.tile_set_name
    $txt_north = GGLib::TextBox.new("TileYaml", $window.board_width + 150, 50, 100, GGLib::Themes::Shade,150,50)
    $txt_south = GGLib::TextBox.new("TileYaml", $window.board_width + 150, 150, 100, GGLib::Themes::Shade,150,50)
    $txt_west = GGLib::TextBox.new("TileYaml", $window.board_width, 100, 100, GGLib::Themes::Shade,150,50)
    $txt_east = GGLib::TextBox.new("TileYaml", $window.board_width + 300, 100, 100, GGLib::Themes::Shade,150,50)
    $txt_center = GGLib::TextBox.new("TileYaml", $window.board_width + 150, 100, 100, GGLib::Themes::Shade,150,50)
    # GGLib::Button.new("button1", "Save", $window.board_width, 450, Proc.new{ |widget| $txt_tileset_name.text = "Not working yet" }, GGLib::Themes::Shade)
    GGLib::Button.new("button2", "Exit", 0, $window.board_height, Proc.new{ |widget| $window.close; exit }, GGLib::Themes::Shade)
  end

  #This method is called right after our state object looses
  #ownership of the window. The window is automatically reset, but
  #if you modified anything other than the window, this is where you
  #should clean it up.
  def onEnd
    puts "TileEditorStateObj terminated."
  end
end