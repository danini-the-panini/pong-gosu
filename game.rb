require 'gosu'

WIDTH = 640
HEIGHT = 480
FULLSCREEN = false

class Entity
  attr_accessor :x, :y

  def initialize x, y, sprite
    @x = x
    @y = y
    @sprite = sprite
  end

  def width
    @sprite.width
  end

  def height
    @sprite.height
  end

  def draw
    @sprite.draw x, y, 0
  end
end

class Ball < Entity
  attr_accessor :vx, :vy

  def initialize x, y, vx, vy, sprite
    super x, y, sprite
    @vx = vx
    @vy = vy
  end

  def reset
    @x = WIDTH/2-width/2
    @y = HEIGHT/2-height/2
    @vx = @vy = 2
  end

  def update
    @x += @vx
    @y += @vy

    if @y < 0 || @y > HEIGHT-height
      @vy = -@vy
    end
  end
end

class Paddle < Entity
  attr_accessor :up, :down, :score

  def initialize x, y, sprite
    super
    @score = 0
  end

  def collides? ball
    ball.x < x+width && ball.x+ball.width > x &&
      ball.y < y+height && ball.y+ball.height > y
  end

  def update
    if @up
      @y -= 2.5
    end
    if @down
      @y += 2.5
    end
  end
end

class Pong < Gosu::Window
  def initialize
    super WIDTH, HEIGHT, FULLSCREEN

    @ball_image = Gosu::Image.new self, "ball.png"
    @paddle_image = Gosu::Image.new self, "paddle.png"

    @ball = Ball.new WIDTH/2 - @ball_image.width/2, HEIGHT/2 - @ball_image.height/2, 2, 2, @ball_image

    @left_paddle = Paddle.new(@paddle_image.width, HEIGHT/2 - @paddle_image.height/2, @paddle_image)
    @right_paddle = Paddle.new(WIDTH - @paddle_image.width*2, HEIGHT/2 - @paddle_image.height/2, @paddle_image)

    @left_score = score_image @left_paddle
    @right_score = score_image @right_paddle
  end

  def score_image paddle
    Gosu::Image.from_text(self, paddle.score.to_s, Gosu::default_font_name, 72)
  end

  def button_down id
    case id
    when Gosu::KbQ
      @left_paddle.up = true
    when Gosu::KbA
      @left_paddle.down = true
    when Gosu::KbP
      @right_paddle.up = true
    when Gosu::KbL
      @right_paddle.down = true
    end
  end

  def button_up id
    case id
    when Gosu::KbQ
      @left_paddle.up = false
    when Gosu::KbA
      @left_paddle.down = false
    when Gosu::KbP
      @right_paddle.up = false
    when Gosu::KbL
      @right_paddle.down = false
    end
  end

  def update
    @ball.update
    @left_paddle.update
    @right_paddle.update

    if @left_paddle.collides?(@ball) || @right_paddle.collides?(@ball)
      @ball.vx = -@ball.vx
      @ball.vx *= 1.1
      @ball.vy *= 1.1
    end

    if @ball.x < -@ball.width
      @right_paddle.score += 1
      @right_score = score_image @right_paddle
      @ball.reset
    end
    if @ball.x > WIDTH
      @left_paddle.score += 1
      @left_score = score_image @left_paddle
      @ball.reset
    end
  end

  def draw
    @ball.draw
    @left_paddle.draw
    @right_paddle.draw

    @left_score.draw WIDTH*0.25 - @left_score.width/2, HEIGHT*0.25-@left_score.height/2, 0
    @right_score.draw WIDTH*0.75 - @left_score.width/2, HEIGHT*0.25-@left_score.height/2, 0
  end
end

Pong.new.show
