require 'gosu'

class Apple
  attr_reader :x, :y
  POS = 640 / 16

  def self.sprite=(sprite)
    @@sprite = sprite
  end
  
  def initialize
    new_position
  end

  def new_position
    @x, @y = rand(POS) * 16, rand(POS) * 16
  end

  def update

  end

  def draw
    @@sprite.draw(x,y,0)
  end
end

class SnakeBlock
  attr_reader :x, :y
  def initialize(x, y)
    @x, @y = x, y
  end

  def self.sprite=(sprite)
    @@sprite = sprite
  end

  def draw
    @@sprite.draw(x,y,0)
  end
end

class Snake
  BLOCK_SIZE = 16
  DIRECTIONS = {
    up: Proc.new{(SnakeBlock.new(last_block.x, last_block.y - BLOCK_SIZE))},
    left: Proc.new{(SnakeBlock.new(last_block.x - BLOCK_SIZE, last_block.y))},
    down: Proc.new{(SnakeBlock.new(last_block.x, last_block.y + BLOCK_SIZE))},
    right: Proc.new{(SnakeBlock.new(last_block.x + BLOCK_SIZE, last_block.y))}
  }

  def initialize
    @active = true
    @direction = :up
    @blocks = [SnakeBlock.new(320, 320)]
    add_block
    add_block
    @last_move = @last_update = Gosu::milliseconds
  end

  def last_block
    @blocks.last
  end

  def can_update?
    time = Gosu::milliseconds
    if time - @last_update > 100
      @last_update = time
    end
  end

  def stop!
    @active = false
  end

  def active?
    @active
  end

  def up
    @direction = :up unless @direction == :down
  end

  def down
    @direction = :down unless @direction == :up
  end

  def left
    @direction = :left unless @direction == :right
  end

  def right
    @direction = :right unless @direction == :left
  end
  
  def update
    if @active && can_update?
      add_block
      @blocks.shift
    end
  end

  def add_block
    @blocks<< instance_eval(&DIRECTIONS[@direction])
  end

  def eat_it_self?
    @blocks[0...-1].any? do |block|
      eat?(block)
    end
  end

  def eat?(apple)
    last_block.x == apple.x && last_block.y == apple.y
  end

  def out?
    last_block.x >= GameWindow::WIDTH || last_block.y >= GameWindow::HEIGHT || last_block.x <= 0 || last_block.y <= 0
  end

  def draw
    @blocks.each(&:draw)
  end
end

class GameWindow < Gosu::Window

  WIDTH = HEIGHT = 640

  def initialize
    super(WIDTH, HEIGHT, false)
    Apple.sprite = SnakeBlock.sprite = Gosu::Image.new(self, "images/snake.png", true)
    self.caption = 'Snake'
    @font = Gosu::Font.new(self, Gosu::default_font_name, 50)
    @snake = Snake.new
    @apple = Apple.new
  end

  def update
    if @snake.eat_it_self? || @snake.out?
      @snake.stop!
    elsif @snake.eat?(@apple)
      @apple.new_position
      @snake.add_block
    end

    if button_down? Gosu::KbLeft
      @snake.left
    elsif button_down? Gosu::KbRight
      @snake.right
    elsif button_down? Gosu::KbUp
      @snake.up
    elsif button_down? Gosu::KbDown
      @snake.down
    end

    @snake.update
    @apple.update
  end

  def draw
    @snake.draw
    @apple.draw
    unless @snake.active?
      @font.draw_rel("GAME OVER!", 300, 300, 5, 0.5, 0.5)
    end
  end
end

gwindow = GameWindow.new
gwindow.show
