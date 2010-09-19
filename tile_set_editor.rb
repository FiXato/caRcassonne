require 'rubygems'
require 'tile'
require 'tile_set'
require 'grid'
require 'gosu'
require "gglib"
require "ext/widgets"
require "ext/themes"
require "yaml"
class TileSetEditor < GGLib::GUIWindow
  attr_accessor :grid, :grid2, :tile_width, :tile_height, :tile_set, :tile_set_name, :board_max_tiles_x, :board_max_tiles_y, :ticks
  attr_reader :width, :height

  def initialize(caption="Tile Editor",config={})
    config.keys.each do |k|
      self.send("#{k}=",config[k]) if self.methods.include?("#{k}=")
    end
    tile_set = TileSet.load(tile_set_name)
    self.tile_set = tile_set
    self.tile_width = 100#tile_set.tile_dimensions[0]
    self.tile_height = 100 #tile_set.tile_dimensions[1]

    @ticks = 0
    tile_set.uniq_shuffled_tiles!
    self.grid = Grid.new
    self.grid.max_x = board_width / tile_width
    self.grid.max_y = board_height / tile_height
    self.grid2 = Grid.new
    self.grid2.max_x = board_width / tile_width
    self.grid2.max_y = board_height / tile_height
    self.grid2.offset = {:x => board_width+10, :y => 0}

    super(board_width + (5*tile_width), board_height + (2 * tile_height), false)
    self.caption = caption
    self.state = TileSetEditorStateObj.new
    self.add_all_tiles_to_grid
  end

  def board_width
    board_max_tiles_x * tile_width
  end

  def board_height
    board_max_tiles_y * tile_height
  end

  def add_all_tiles_to_grid(grid=nil,tiles=nil)
    grid = self.grid if grid.nil?
    tiles = tile_set.shuffled_tiles if tiles.nil?
    puts tiles.size
    cur_x = 0
    cur_y = 0
    tiles.sort_by{|tile|tile.graphic}.each do |tile|
      grid.place_tile!(tile,cur_x,cur_y)
      cur_x += 1
      if cur_x > (grid.max_x-1)
        cur_x = 0
        cur_y += 1
      end
    end
  rescue OutOfTilesException
  end
end
class TileSetEditorStateObj < GGLib::StateObject
  attr_accessor :tile_set, :tile_width, :tile_height
  def initialize
    @tile_set = $window.tile_set
    @tile_width = $window.tile_width
    @tile_height = $window.tile_height
    @replacement_tiles = {}
    super
  end

  def grid
    $window.grid
  end

  def grid2
    $window.grid2
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
      unless @current_tile[:grid_x] == grid.max_x - 1
        @current_tile[:grid_x] += 1
      end
    when Gosu::Button::KbDown, Gosu::Button::GpDown
      unless @current_tile[:grid_y] == grid.max_y - 1
        @current_tile[:grid_y] += 1 
      end
    when Gosu::Button::KbUp, Gosu::Button::GpUp
      unless @current_tile[:grid_y] == 0
        @current_tile[:grid_y] -= 1
      end
    when Gosu::Button::KbReturn, Gosu::Button::GpButton1
      puts 'Trying to select tile at %sx%s' % [@current_tile[:grid_x],@current_tile[:grid_y]]
      if grid.has_tile?(@current_tile[:grid_x],@current_tile[:grid_y])
        @selected_tile = grid.tile(@current_tile[:grid_x],@current_tile[:grid_y])
        [:north,:south,:west,:east,:center].each do |direction|
          @txt[direction].text = [@selected_tile.send(direction)].flatten.join(", ") if @selected_tile.kind_of?(Tile)
        end
      end
    when Gosu::Button::MsLeft
      x = $window.mouse_x
      y = $window.mouse_y
      replacement_tiles_min_x = grid2.offset[:x]
      replacement_tiles_min_y = grid2.offset[:y]
      replacement_tiles_max_x = grid2.offset[:x] + $window.board_width
      replacement_tiles_max_y = grid2.offset[:y] + $window.board_height
      if(x >= replacement_tiles_min_x && x <= replacement_tiles_max_x && y >= replacement_tiles_min_y && y <= replacement_tiles_max_y)
        relative_x = x - grid2.offset[:x]
        relative_y = y - grid2.offset[:y]
        puts "within replacement tiles grid at #{relative_x}, #{relative_y}"
        grid_x = (relative_x / $window.tile_width).floor
        grid_y = (relative_y / $window.tile_height).floor
        puts "grid coords: #{grid_x}, #{grid_y}"
        if tile = grid2.tile(grid_x,grid_y)
          if @selected_tile
            puts "Before: #{grid.tiles.size}"
            grid.tiles.reject!{|t|t[0] == @current_tile[:grid_x] && t[1] == @current_tile[:grid_y]}
            puts "After: #{grid.tiles.size}"
            @selected_tile.gosu_image = nil
            @selected_tile.graphic = tile.graphic
            grid.place_tile!(@selected_tile,@current_tile[:grid_x],@current_tile[:grid_y])
          else
            puts "no tile selected"
          end
        end
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
    grid.draw($window)
    grid2.draw($window) if grid2
    @current_tile[:image].draw_rot(@current_tile[:grid_x] * tile_width + 50,@current_tile[:grid_y] * tile_height + 50,0,0) if @current_tile
  end

  def set_background(filename)
    @background_image = Gosu::Image.new(self, filename, true)
  end

  def onStart
    puts "TileSetEditorStateObj activated."
    # $window.setBackground("resources/backgrounds/grey_outline.png")
    @txt = {}
    @btn = {}
    @txt[:north]  = GGLib::TextBox.new("TileYaml", 150, 0  + $window.board_height, 100, GGLib::Themes::Shade,150,50)
    @txt[:south]  = GGLib::TextBox.new("TileYaml", 150, 100 + $window.board_height, 100, GGLib::Themes::Shade,150,50)
    @txt[:west]   = GGLib::TextBox.new("TileYaml", 0,   50  + $window.board_height, 100, GGLib::Themes::Shade,150,50)
    @txt[:east]   = GGLib::TextBox.new("TileYaml", 300, 50  + $window.board_height, 100, GGLib::Themes::Shade,150,50)
    @txt[:center] = GGLib::TextBox.new("TileYaml", 150, 50  + $window.board_height, 100, GGLib::Themes::Shade,150,50)
    @txt[:tileset_name] = GGLib::TextBox.new("TileSetName", $window.board_width, $window.board_height, 100, GGLib::Themes::Shade,300,50)
    @txt[:tileset_name].text = $window.tile_set_name
    @btn[:dirs]   = []
    Dir.glob("resources/tiles/*/").each_with_index do |dir,idx|
      @btn[:dirs] << GGLib::Button.new("btnDir#{dir}", 
      File.basename(dir), 
      $window.board_width, 
      $window.board_height + 60 + (idx * 25), 
      Proc.new{ |widget| dirname = File.join(dir,'*.png').gsub("[","\\[").gsub("]", "\\]");@tile_images = Dir.glob(dirname);add_tile_images }, 
      GGLib::Themes::Shade,
      300)
    end
    # GGLib::Button.new("button1", "Save", $window.board_width, 450, Proc.new{ |widget| $txt_tileset_name.text = "Not working yet" }, GGLib::Themes::Shade)
    GGLib::Button.new("button2", "Exit", $window.board_width + 300, $window.board_height, Proc.new{ |widget| $window.close; exit }, GGLib::Themes::Shade)
  end

  def add_tile_images
    puts "draw_tile_images"
    @replacement_tiles = []
    puts @tile_images.size
    @tile_images.each do |image|
      # @tile_image_objects[image] ||= Gosu::Image.new($window, File.expand_path(image), true)
      @replacement_tiles << Tile.new(:image,image)
    end
    grid2.tiles = []
    $window.add_all_tiles_to_grid(grid2,@replacement_tiles)
  end

  #This method is called right after our state object looses
  #ownership of the window. The window is automatically reset, but
  #if you modified anything other than the window, this is where you
  #should clean it up.
  def onEnd
    puts "TileSetEditorStateObj terminated."
  end
end