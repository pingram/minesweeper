class Tile

  #position is 2d array
  attr_accessor :position, :value, :showed_value

  def initialize(position, value)
    @position = position
    @value = value
    @showed_value = "*"
  end

  def bombed?
    @value == 'B'
  end

  def flagged?
    @showed_value == 'F'
  end

  def revealed?
    @showed_value != '*'
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
    r = Random.new
    mines_remaining = @mine_count
    until mines_remaining <=0
      tile = board[r.rand(@board_size)][r.rand(@board_size)]
      unless tile.bombed?
        tile.value = 'B'
        mines_remaning -= 1
      end
    end
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


  def place_mine(tile)
    if title.bombed?
      #increment neighbor by 1 if they are not bombed
    else

  end

  def tile_at(pos)
    board[pos.first][pos.last]
  end


  NEIGHBOR_DELTA = {
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
    NEIGHBOR_DELTA.each do |_, delta|
      new_pos = [delta.first + tile.row, delta.last + tile.col]
      valid_neighbors << tile_at(new_pos) if in_bound?(pos, board_size)
    end
    valid_neighbors
  end

  def neighbor_bomb_count(tile)
    tile_neighbors = neighbors(tile)
    tile_neighbors.inject(0) do |bomb_count, neighbor|
      bomb_count += 1  if neighbor.value == 'B'
    end
    bomb_count
  end

  def neighbor_flag_count(tile)
    tile_neighbors = neighbors(tile)
    tile_neighbors.inject(0) do |flag_count, neighbor|
      flag_count += 1  if neighbor.showed_value == 'F'
    end
    flag_count
  end

  def reveal(tile)
    #base case
    if tile.num?
      tile.showed_value = tile.value
      return ""
    end

    #bomb
    return "Game Over" if tile.bombed?

    #already clicked
    return "" if (tile.revealed? || tile.flagged?)

    neighbors(tile).each do |neighbor|
      #will still run reveal even regardless of whether game over
      return "Game Over" if reveal(neighbor) == "Game Over"
    end
  end

end

  def in_bound?(pos)
    (0...self.board_size).cover?(pos.first) && (0...self.board_size).cover?(pos.last)
  end

end


class Minesweeper

  def initialize

  end
end


class Render

end