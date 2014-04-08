require 'debugger'
require 'colorize'
require 'yaml'

UNICODE_HASH = {:black_block => "\u25A7",
  :black_flag => "\u2691"}

class Tile

  #position is 2d array
  attr_accessor :position, :value, :showed_value

  def initialize(position, value)
    @position = position
    @value = value
    @showed_value = UNICODE_HASH[:black_block]
  end

  def bombed?
    @value == 'B'
  end

  def flagged?
    @showed_value == UNICODE_HASH[:black_flag]
  end

  def revealed?
    (@showed_value != UNICODE_HASH[:black_block] &&
    @showed_value != UNICODE_HASH[:black_flag])
  end

  def num? # (1..8).cover? self.value.to_i
    begin
      Integer(self.value)
    rescue
      return false
    end
    true
  end

  def row
    @position.first
  end

  def col
    @position.last
  end
end


class Board
  attr_accessor :board, :board_size, :mine_count

  def initialize(mine_count, board_size)
    @mine_count = mine_count
    @board_size = board_size
    @board = Array.new(@board_size){Array.new(@board_size)}

    place_tiles
    place_mines
    increment_tile_counts
  end

  def place_tiles
    (0...@board_size).each do |row|
      (0...@board_size).each do |col|
        @board[row][col] = Tile.new([row, col]," ")
      end
    end
  end


  def place_mines
    @board.flatten.sample(@mine_count).each { |tile| tile.value = 'B'}
    # r = Random.new
    # mines_remaining = @mine_count
    # until mines_remaining <= 0
    #   tile = board[r.rand(@board_size)][r.rand(@board_size)]
    #   unless tile.bombed?
    #     tile.value = 'B'
    #     mines_remaining -= 1
    #   end
    # end
  end

  def increment_tile_counts
    (0...@board_size).each do |row|
      (0...@board_size).each do |col|
        tile = board[row][col]
        unless tile.bombed?
          tile.value = neighbor_bomb_count(tile).to_s
        end
      end
    end
  end

  def tile_at(pos)
    board[pos.first][pos.last]
  end

  def set_flag(pos)
    # debugger

    if tile_at(pos).revealed?
      return false
    elsif tile_at(pos).showed_value == UNICODE_HASH[:black_flag]
      tile_at(pos).showed_value = UNICODE_HASH[:black_block]
    else
      tile_at(pos).showed_value = UNICODE_HASH[:black_flag]
    end
  end

  @@NEIGHBOR_DELTA = {
    0 => [-1, -1],
    1 => [-1, 0],
    2 => [-1, 1],
    3 => [0, -1],
    4 => [0, 1],
    5 => [1, -1],
    6 => [1, 0],
    7 => [1, 1]
  }


  def neighbors(tile)
    valid_neighbors = []
    @@NEIGHBOR_DELTA.each do |_, delta|
      new_pos = [delta.first + tile.row, delta.last + tile.col]
      valid_neighbors << tile_at(new_pos) if in_bound?(new_pos)
    end
    valid_neighbors
  end

  def neighbor_bomb_count(tile)
    tile_neighbors = neighbors(tile)
    bomb_count = 0
    tile_neighbors.each do |neighbor|
      bomb_count += 1  if neighbor.value == 'B'
    end
    bomb_count
  end

  def neighbor_flag_count(tile)
    tile_neighbors = neighbors(tile)
    flag_count = 0
    tile_neighbors.each do |neighbor|
      flag_count += 1  if neighbor.showed_value == UNICODE_HASH[:black_flag]
    end
    flag_count
  end

  def init_memo
    @memo = Hash.new(false)
  end

  def reveal(tile) #clicks on a tile

    return "" if tile.flagged?
    if (tile.revealed? && neighbor_flag_count(tile) == tile.value.to_i && tile.value.to_i != 0)
      neighbors(tile).each do |neighbor|
        #will still run reveal even regardless of whether game over
        unless neighbor.revealed?
          return "Game Over" if reveal(neighbor) == "Game Over"
        end
      end
    end

    #base case
    if tile.num?
      if tile.value.to_i == 0
        tile.showed_value = "_"
      else
        tile.showed_value = tile.value
        return ""
      end
    end

    #bomb
    return "Game Over" if tile.bombed?

    #already clicked

    if @memo[tile]!= true
      @memo[tile] = true
      neighbors(tile).each do |neighbor|
        #will still run reveal even regardless of whether game over
        return "Game Over" if reveal(neighbor) == "Game Over"
      end
    end
  end

  def in_bound?(pos)
    (0...self.board_size).cover?(pos.first) && (0...self.board_size).cover?(pos.last)
  end

  def colorize_output(char)
    if char == UNICODE_HASH[:black_flag]
      char.colorize(:light_red)
    elsif char == UNICODE_HASH[:black_block]
      char.colorize(:white)
    elsif char == "1"
      char.colorize(:blue)
    elsif char == "2"
      char.colorize(:green)
    elsif char == "3"
      char.colorize(:red)
    elsif char == "4"
      char.colorize(:magenta)
    elsif char == "_"
      char = " "
    else
      return char
    end
  end

  def render
    print "  "
    (0...@board_size).each do |i|
      print "#{i.to_s.colorize(:white)} "
    end
    print "\n"
    (0...@board_size).each do |row|
      print "#{row.to_s.colorize(:white)} "
      (0...@board_size).each do |col|
        print colorize_output(board[row][col].showed_value) + ' '
      end
      print "\n"
    end
  end

  def render_answer
    print "  "
    (0...@board_size).each do |i|
      print "#{i} "
    end
    print "\n"
    (0...@board_size).each do |row|
      print "#{row} "
      (0...@board_size).each do |col|
        print board[row][col].value + ' '
      end
      print "\n"
    end
    print "\n"
  end
end


class Minesweeper

  def initialize(mine_count, board_size)
    @board = Board.new(mine_count, board_size)
  end

  def run
    puts "\nWelcome to my minesweeper,there are #{@board.mine_count} mines!"
    puts "To save your game, enter 's'. To load a game, enter 'l'\n\n"
    while true

      @board.render_answer
      @board.render
      puts "Where would you like to move(0 0):"
      user_input = get_valid_input


      if user_input[0] == 'l'
        load
      elsif user_input[0] == 's'
        save
      elsif user_input[0] == 'f'
        pos = [user_input[1], user_input[2]]
        @board.set_flag(pos)
      else
        pos = [user_input.first, user_input.last]
        @board.init_memo
        reveal_returned = @board.reveal(@board.tile_at(pos))
      end

      if won?
        @board.render
        puts "Congratualation! You Won!"
        break
      end

      break if reveal_returned == "Game Over"
      print "\e[2J"
    end
  end

  def won?
    (0...@board.board_size).each do |row|
      (0...@board.board_size).each do |col|
        tile = @board.tile_at([row,col])
        return false if (!tile.revealed?) && tile.num?
      end
    end
  end

  def save
    puts "Please enter a filename:"
    filename = gets.chomp
    File.open(filename, 'w') do |f|
      f.puts "#{@board.to_yaml}"
    end
  end

  def load
    puts "Which file would you like to load?"
    filename = gets.chomp
    @board = YAML::load(File.read(filename))
  end

  def get_valid_input
    begin
      parsed_input = []
      user_input = gets.chomp.split
      return user_input if (user_input[0] == 'l' || user_input[0] == 's')
      if user_input.first == 'f'
        parsed_input << 'f'
        pos = [Integer(user_input[1]), Integer(user_input[2])]
      else
        pos = [Integer(user_input[0]), Integer(user_input[1])]
      end
      raise '' if !@board.in_bound?(pos)
    rescue
      puts "Invalid input, please try again"
      retry
    end
    parsed_input += pos
  end

  def lost?

  end

end

def test
   # b = Board.new(20, 10)
   #    b.render
   m = Minesweeper.new(2,10)
   m.run
end

test