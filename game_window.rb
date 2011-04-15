# encoding: utf-8
require 'rubygems'
require 'gosu'
require 'player'
require "yaml"
class GameWindow < Gosu::Window
  attr_accessor :grid, :tile_width, :tile_height, :tile_set, :save_state_filename, :players, :turn, :current_pawn, :phase
  attr_reader :width, :height, :player_colours
  ZORDER = {:bg => 0, :tiles => 1, :current_tile => 2, :pawns => 3, :text => 4}

  def initialize(caption="Gosu Application",width=800,height=600)
    super(width, height + 200, false)
    @width = width
    @height = height
    self.caption = caption
    @save_state_filename = File.expand_path(File.join("savestates",Time.now.strftime("%Y%m%d%H%M%S")+".yaml"))
    @players = []
    @ticks = 0
    @turn = 0
    @turn_text = Gosu::Font.new(self,'Verdana', 20)
    @current_tile_texts = []
    3.times{@current_tile_texts << Gosu::Font.new(self,File.expand_path("resources/FixedSysExcelsior300.ttf"), 40)}
    @player_colours = [
      0xffffffff,
      0xffff0000,
      0xff00ff00,
      0xffffff00,
      0xff00ffff,
      0xffff00ff,
      0xff888800,
      0xff008888,
      0xffff8c00
    ]
    @current_pawn = nil
    @phase = :tile
  end

  def add_player(name)
    self.players << Player.new(name)
  end

  def players_texts
    @players_texts ||= players.map{Gosu::Font.new(self,File.expand_path("resources/FixedSysExcelsior300.ttf"), 20)}
  end

  # def update
  #   @ticks += 1
  #   return unless @ticks % 5 == 1
  # rescue OutOfTilesException
  #   puts "No more tiles available!" unless @game_ended
  #   end_game
  # end

  def draw
    draw_background
    grid.draw(self)
    draw_pawns
    draw_status_texts
    draw_current_pawn if current_pawn
    draw_current_tile
  rescue OutOfTilesException
    puts "No more tiles available!" unless @game_ended
    end_game
  end

  def draw_status_texts
    text = "Turn #{turn}, #{current_player.name}'s move: " if players.size > 0
    @turn_text.draw(text, 0, height + 10, ZORDER[:text], 1, 1, 0xffffffff)
    players_texts.each_with_index do |font,idx|
      player = players[idx]
      font.draw(player.name + ' ' * (20-player.name.size) + '☃' * (pawns = player.available_pawns.size) + ('(%s)' % pawns), width / 2, height + 10 + (idx * 20), ZORDER[:text], 1, 1, player_colours[idx])
    end
  end

  def draw_pawns
    players.each do |player|
      player.placed_pawns.each do |pawn|
        draw_pawn(pawn)
      end
    end
  end

  def draw_background
    if @background_image
      (0..(@width/tile_width)).each do |x_index|
        offset_x = x_index * tile_width
        (0..(@height/tile_height)).each do |y_index|
          offset_y = y_index * tile_height
          @background_image.draw(offset_x - 1, offset_y - 1, ZORDER[:bg])
        end
      end
    end
  end

  def draw_current_tile
    x = current_tile[:grid_x] * tile_width + tile_width/2
    y = current_tile[:grid_y] * tile_height + tile_height/2
    current_tile[:image].draw_rot(x,y,ZORDER[:current_tile],current_tile[:tile].rotation) if current_tile
    graphs = current_tile[:tile].to_graphs
    colour = (players.size > 0 ? player_colours[turn % players.size] : 0xffff0000)
    @current_tile_texts.each_with_index do |font,idx|
      font.draw(graphs[idx].join('').gsub(' ','█').gsub('·', '⃞').gsub('#','❑'), ZORDER[:text], height + 30 + (idx * 40), 0, 1, 1, colour)
    end
  end

  def draw_current_pawn
    draw_pawn(current_pawn)
  end

  def draw_pawn(pawn)
    x = (pawn.grid_position[:x] * tile_width) + (pawn.sub_grid_position[:x] * (tile_width/3))
    y = (pawn.grid_position[:y] * tile_height) + (pawn.sub_grid_position[:y] * (tile_height/3))
    pawn.image.draw(x,y,ZORDER[:pawns])
  end

  def set_background(filename)
    @background_image = Gosu::Image.new(self, filename, true)
  end

  def current_tile
    @current_tile ||= get_current_tile
  end

  def get_current_tile
    tile = tile_set.get_tile
    puts "New tile taken from stack: "
    tile.draw_graphs
    puts tile.sub_grid.map{|l|l.join(", ")}.join("\n")
    {
      :tile => tile,
      :image => Gosu::Image.new(self, tile.graphic, true),
      :grid_x => 0,
      :grid_y => 0,
      :x => tile_width / 2,
      :y => tile_height / 2,
    }
  end

  def place_pawn
    current_pawn.position = :board
    current_player.update_available_pawns
    @current_pawn = nil
  end

  def place_pawn_phase
    @phase = :pawn
    return end_turn unless @current_pawn = current_player.get_available_pawn
    @current_pawn.image = Gosu::Image.new(self, File.expand_path(File.join('resources','pawn.png')), true)
    @current_pawn.grid_position[:x] = @current_tile[:grid_x]
    @current_pawn.grid_position[:y] = @current_tile[:grid_y]
  end

  def end_turn
    place_pawn if current_pawn
    @turn += 1
    @current_tile = nil
    save_state
    grid.draw_text
    print "Turn #{turn}"
    print ", #{current_player.name}'s move: " if players.size>0
    print "\n"
    @phase = :tile
  end

  def current_player
    players[turn % players.size]
  end

  def end_game
    @tile_set.empty_tiles
    @current_tile = nil
    @game_ended = true
  end

  def button_up(id)
    case id 
    when Gosu::Button::KbEscape
      close
    when Gosu::Button::KbBackspace, Gosu::Button::GpButton2
      puts "Game was ended prematurely"
      end_game
    end

    if phase == :tile
      case id
      when Gosu::Button::KbLeft, Gosu::Button::GpLeft
        current_tile[:grid_x] -= 1 unless current_tile[:grid_x] == 0
      when Gosu::Button::KbRight, Gosu::Button::GpRight
        current_tile[:grid_x] += 1 unless current_tile[:grid_x] == grid.max_x
      when Gosu::Button::KbDown, Gosu::Button::GpDown
        current_tile[:grid_y] += 1 unless current_tile[:grid_y] == grid.max_y
      when Gosu::Button::KbUp, Gosu::Button::GpUp
        current_tile[:grid_y] -= 1 unless current_tile[:grid_y] == 0
      when Gosu::Button::KbSpace, Gosu::Button::GpButton0, Gosu::Button::MsRight
        current_tile[:tile].rotate_clockwise
        puts "Rotated tile clockwise:"
        current_tile[:tile].draw_graphs
        puts current_tile[:tile].sub_grid.map{|l|l.join(", ")}.join("\n")
      when Gosu::Button::KbReturn, Gosu::Button::GpButton1, Gosu::Button::MsLeft
        puts 'Trying to place tile at %sx%s' % [current_tile[:grid_x],current_tile[:grid_y]]
        place_pawn_phase if grid.place_tile(current_tile[:tile],current_tile[:grid_x],current_tile[:grid_y])
      when Gosu::Button::KbS
        skip_tile
      end
    elsif phase == :pawn
      case id
      when Gosu::Button::KbLeft, Gosu::Button::GpLeft
        current_pawn.sub_grid_position[:x] -= 1 unless current_pawn.sub_grid_position[:x] == 0
      when Gosu::Button::KbRight, Gosu::Button::GpRight
        current_pawn.sub_grid_position[:x] += 1 unless current_pawn.sub_grid_position[:x] == 2
      when Gosu::Button::KbDown, Gosu::Button::GpDown
        current_pawn.sub_grid_position[:y] += 1 unless current_pawn.sub_grid_position[:y] == 2
      when Gosu::Button::KbUp, Gosu::Button::GpUp
        current_pawn.sub_grid_position[:y] -= 1 unless current_pawn.sub_grid_position[:y] == 0
      when Gosu::Button::KbSpace, Gosu::Button::GpButton0, Gosu::Button::MsRight
        puts "Skipping pawn placement."
        @current_pawn = nil
        end_turn
      when Gosu::Button::KbReturn, Gosu::Button::GpButton1, Gosu::Button::MsLeft
        puts 'Trying to place pawn at %sx%s' % [current_pawn.sub_grid_position[:x],current_pawn.sub_grid_position[:y]]
        end_turn# if current_player.place_pawn(current_pawn)
      end
    end
  end

  def save_state
    # Disabled for now till the to-be-saved/restored information is a bit more clear/stable.
    # dup_grid = grid.dup
    # dup_grid.tiles.each {|tile|tile[2].gosu_image = nil} #kill the gosu images, because they can't be imported.
    # save_state = {:grid => dup_grid, :tile_set => tile_set}
    # File.open(save_state_filename, "w") { |file| YAML.dump(save_state, file) }
  end

  #TODO: Add checks here to see if the tile is allowed to be skipped (not placeable tile)
  def skip_tile
    tile_set.shuffle_into_stack(@current_tile[:tile])
    puts "Tile was skipped"
    @current_tile = nil
  end
end