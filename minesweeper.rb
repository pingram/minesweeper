class Tile

  #position is 2d array
  attr_accessor :position, :value, :showed_val

  def bombed?

  end

  def flagged?
    @showed_val == 'F'
  end

  def revealed?

  end

  def reveal

  end

  def neighbors

  end

  def neighbor_bomb_count

  end

end

class Board

end

class Minesweeper

end