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
    shuffled_tiles.shift
  end

  #TODO: Validate all tiles to make sure each side of every tile is specified
  def validate
    tiles.each do |tile|
      [:north,:south,:west,:east].each do |direction|
        puts "#{tile.graphic}(#{tile.type}): #{direction} is missing" if tile.send(direction).nil?
      end
    end
    nil
  end
end