class Tile

  #position is 2d array
  attr_accessor :position, :value, :showed_value, :board_size

  def initialize(position, value, board_size)
    @position = position
    @value = value
    @board_size = board_size
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



  def row
    @position.first
  end

  def col
    @position.last
  end


end


class Board
  attr_accessor :board, :board_size

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

  def reveal(tile)
    return "" if (tile.revealed? || tile.flagged?)
    return "Game Over" if tile.bombed?


    neighbors(tile).each do |neighbor|
      reveal(neighbor)
    end

    # finish writing xxx
  end

  def in_bound?(pos)
    (0...self.board_size).cover?(pos.first) && (0...self.board_size).cover?(pos.last)
  end

end


class Minesweeper

end


class Render

end