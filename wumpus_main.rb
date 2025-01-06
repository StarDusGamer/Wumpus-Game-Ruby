class Location
  def print
    "O"
  end

  def visit
    puts ""
  end
end

class Pit < Location
  def print
    "O"  # Hidden as "O" during gameplay
  end

  def visit
    puts "Ahhhh! You fell into a pit..."
  end
end

class Wumpus < Location
  def print
    "O"  # Hidden as "O" during gameplay
  end

  def visit
    puts "Uh oh! You got eaten by the wumpus..."
  end
end

class Game
  attr_accessor :maze, :player_x, :player_y, :game_state

  BOARD_SIZE_X = 6
  BOARD_SIZE_Y = 4
  NUM_PITS = 4

  def initialize
    @maze = Array.new(BOARD_SIZE_Y) { Array.new(BOARD_SIZE_X) { Location.new } }
    @player_x = 0
    @player_y = BOARD_SIZE_Y - 1
    @game_state = 0

    add_pits
    add_wumpus
  end

  def add_pits
    pit_positions = []

    while pit_positions.size < NUM_PITS
      x, y = rand(BOARD_SIZE_X), rand(BOARD_SIZE_Y)
      position = [x, y]

      # Ensure valid space and uniqueness
      if valid_space?(x, y) && !pit_positions.include?(position)
        @maze[y][x] = Pit.new
        pit_positions << position
      end
    end
  end

  def add_wumpus
    loop do
      x, y = rand(BOARD_SIZE_X), rand(BOARD_SIZE_Y)
      if valid_space?(x, y)
        @maze[y][x] = Wumpus.new
        break
      end
    end
  end

  def valid_space?(x, y)
    !(x == 0 && y == BOARD_SIZE_Y - 1) && @maze[y][x].is_a?(Location) && (x != 0 && y != 1) && (x != 1 && y != 0)
  end

  def print_board
    @maze.each_with_index do |row, y|
      row.each_with_index do |location, x|
        if x == @player_x && y == @player_y
          print "X "  # Show player location
        else
          print "#{location.print} "  # Hide everything else
        end
      end
      puts ""
    end
  end

  def reveal_board
    @maze.each_with_index do |row, y|
      row.each_with_index do |location, x|
        if location.is_a?(Pit)
          print "p "  # Show pits
        elsif location.is_a?(Wumpus)
          print "w "  # Show Wumpus
        else
          print "O "  # Show empty locations
        end
      end
      puts ""
    end
  end

  def play
    until @game_state != 0
      print_board
      check_breeze_and_stench
      print_options
      input = gets.chomp
      if input == 's'
        print_shoot_options
        shoot(gets.chomp)
      else
        move_player(input)
      end
    end
    puts "Game Over!"
    reveal_board  # Reveal the board upon game over
  end

  def check_breeze_and_stench
    if check_breeze
      puts "You feel a breeze."
    end
    if check_stench
      puts "You smell a stench."
    end
  end

  def check_breeze
    nearby_pit?
  end

  def check_stench
    nearby_wumpus?
  end

  def nearby_pit?
    adjacent_to?(Pit)
  end

  def nearby_wumpus?
    adjacent_to?(Wumpus)
  end

  def adjacent_to?(entity)
    [[@player_y - 1, @player_x], [@player_y + 1, @player_x], [@player_y, @player_x - 1], [@player_y, @player_x + 1]].any? do |y, x|
      y.between?(0, BOARD_SIZE_Y - 1) && x.between?(0, BOARD_SIZE_X - 1) && @maze[y][x].is_a?(entity)
    end
  end

  def print_options
    puts "\n u: move up\n d: move down\n l: move left\n r: move right\n s: shoot arrow\n\nEnter option: "
  end

  def print_shoot_options
    puts "\n u: shoot arrow up\n d: shoot arrow down\n l: shoot arrow left\n r: shoot arrow right\n\nEnter option: "
  end

  def move_player(dir)
    case dir
    when 'u'
      @player_y -= 1 if @player_y > 0
    when 'd'
      @player_y += 1 if @player_y < BOARD_SIZE_Y - 1
    when 'l'
      @player_x -= 1 if @player_x > 0
    when 'r'
      @player_x += 1 if @player_x < BOARD_SIZE_X - 1
    else
      puts "Invalid input!"
    end
    check_position
  end

  def check_position
    @maze[@player_y][@player_x].visit
    check_collide
  end

  def check_collide
    case @maze[@player_y][@player_x]
    when Pit
      @maze[@player_y][@player_x].visit
      @game_state = 1  # End the game when falling into a pit
    when Wumpus
      @maze[@player_y][@player_x].visit
      @game_state = 1  # End the game when eaten by the Wumpus
    end
  end

  def shoot(dir)
    case dir
    when 'u'
      shoot_arrow(@player_y - 1, @player_x)
    when 'd'
      shoot_arrow(@player_y + 1, @player_x)
    when 'l'
      shoot_arrow(@player_y, @player_x - 1)
    when 'r'
      shoot_arrow(@player_y, @player_x + 1)
    else
      puts "Invalid input!"
    end
  end

  def shoot_arrow(y, x)
    if y.between?(0, BOARD_SIZE_Y - 1) && x.between?(0, BOARD_SIZE_X - 1) && @maze[y][x].is_a?(Wumpus)
      puts "You have successfully hunted the Wumpus!"
      @game_state = 1
    else
      puts "You missed the Wumpus."
      @game_state = 1
    end
  end
end

# Start the game
game = Game.new
game.play
