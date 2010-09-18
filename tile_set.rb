require 'tile'
require 'yaml'
require 'fileutils'
class Array
  def unshift_from_find
    element = self.find{|tile|yield tile}
    self.delete(element)
    self.unshift(element)
    self
  end
end
class TileSet
  attr_accessor :tiles, :name, :filename, :tile_dimensions
  
  def initialize(name)
    @name = name
    @tiles = []
    @filename = File.expand_path('tilesets/%s.yaml' % name)
    @tile_dimensions = [90,90]
  end
  
  def add_tile(tile,quantity)
    quantity.times do 
      @tiles << tile.dup
    end
    nil
  end

  def save!(clear_shuffled=true)
    raise 'TileSet is not valid!' unless validate
    @shuffled_tiles = nil if clear_shuffled #Could be useful for saving a game-state
    FileUtils.mkdir_p(File.dirname(filename))
    File.open(filename,'w') { |file| YAML.dump(self, file) }
  end

  def pack!
    tiles.each do |tile|
      tile.graphic_packed = Marshal::dump(File.read(tile.graphic))
    end
    nil
  end

  def unpack!(directory=nil)
    tiles.each do |tile|
      tile.graphic = File.join(directory,File.basename(tile.graphic)) if directory
      File.open(tile.graphic, 'w') do |f|
        f.write(Marshal::load(tile.graphic_packed))
      end
      tile.graphic_packed = nil
    end
    nil
  end

  def self.load(name,filename=nil)
    filename ||= File.expand_path('tilesets/%s.yaml' % name)
    File.open(filename) { |file| YAML.load(file) }
  end

  def shuffled_tiles
    @shuffled_tiles ||= @tiles.dup.sort_by{rand}.unshift_from_find{|tile|tile.type == :start}
  end

  def get_tile
    raise OutOfTilesException unless shuffled_tiles.size > 0
    shuffled_tiles.shift
  end

  def empty_tiles
    @shuffled_tiles = []
  end

  def uniq_shuffled_tiles!
    uniq_tiles = []
    shuffled_tiles.each do |tile|
      unless uniq_tiles.include?(tile)
        uniq_tiles << tile
      end
    end
    @shuffled_tiles = uniq_tiles
  end

  #TODO: Validate all tiles to make sure each side of every tile is specified
  def validate
    error = false
    tiles.each do |tile|
      [:north,:south,:west,:east].each do |direction|
        if tile.send(direction).nil?
          error ||= true
          puts "#{tile.graphic}(#{tile.type}): #{direction} is missing" 
        end
      end
    end
    !error
  end
end
class OutOfTilesException < Exception;end