class Hero
  constructor: ->
    @STATE_SKATING   = 0
    @STATE_JUMPING   = 1
    @STATE_CROUCHING = 2
    @STATE_J_TO_S    = 3

    @max_jump_height = 200

    @width    = 0
    @height   = 0
    @x        = 0
    @y        = 0
    @state    = @STATE_SKATING

    @jump_far = false
    @jumping_time = 0

    @charge_time = 0

  skate: ->
    @tag.attr "src", "/assets/line_skating/skating.png"
    @state = @STATE_SKATING

  jump: ->
    @state = @STATE_JUMPING
    @charge_time = 0
    @jumping_time = 0

  crouch: ->
    @tag.attr "src", "/assets/line_skating/shelter.png"
    @state = @STATE_CROUCHING

  is_skating:   -> @state == @STATE_SKATING

  is_crouching: -> @state == @STATE_CROUCHING

  is_jumping:   -> @state == @STATE_JUMPING

  is_j_to_s:    -> @state == @STATE_J_TO_S

  tag: ->
    @tag = $('<img id="hero">')
    @tag.attr "src",   "/assets/line_skating/skating.png"
    @tag.css "width",  @width + "px"
    @tag.css "height", @height + "px"
    @tag.css "left",   @x + "px"
    @tag.css "top",    @y + "px"
    @tag.css "border", "red 1px solid"


class Obstacle

  constructor: (sort, game) ->
    @sort  = sort
    @width = game.hero.height / 5
    @x     = 940 - @width
    @y     = new Number()
    @need_remove = false

    switch sort
      when 0 then @y = game.hero.y + game.hero.height - @width
      when 1 then @y = game.hero.y

    @tag = $("<div class=\"obstacle\"></div>")

    @tag.css
      "width":  @width
      "height": @width
      "left":   @x
      "top":    @y

    game.el.append(@tag)

class LineSkating extends Spine.Controller

  elements:
    '#line':  'line_div'
    '#score': 'score_div'

  events:
    'click #start': 'game_start'

  constructor: ->
    super
    $(document).keydown  @keydown
    $(document).keyup    @keyup

    @OBSTACLE_MOVE_SPEED   = 10
    @BASE_JUMP_TIME        = 200
    @ADD_OBSTACLE_INTERVAL = 500

    @FPS = 60
    @dt  = 1000.0 / @FPS

    @hero           = new Hero

    @is_start       = false

    #init
    @obstacles      = []
    @SCORE          = 0
    @run_time       = 0

    #load
    @resize()

  keydown: (event) =>
    switch event.keyCode
      when 13
        @game_start()

      when 70 #f
        return unless @is_start
        return if @is_pressing_f
        @is_pressing_f = true

        if @hero.is_skating()
          @hero.crouch()

      when 74 #j
        return unless @is_start
        return if @is_pressing_j
        @is_pressing_j = true

        if not @hero.is_jumping()
          @hero.jump()
          @hero.jump_far = true

  keyup: (event) =>
    switch event.keyCode
      when 13
        @game_start()

      when 70 #f
        return unless @is_start
        @is_pressing_f = false

        if @hero.is_crouching()
          @hero.skate()

      when 74 #j
        return unless @is_start
        @is_pressing_j = false
        @hero.jump_far = false


  resize: =>
    @el_width = @el.width()
    @el_height = @el.height()

    @hero.height = @el_height / 8
    @hero.width = @hero.height * 0.8
    @hero.x = @el_width / 4
    @hero.y = @el_height / 2

    @loadFrame()

    @el.append @hero.tag()

  loadFrame: ->
    @line_div.css "height", @hero.height / 10 + "px"
    @line_div.css "top",    @hero.y + @hero.height

    @score_div.css "fontSize", @el_width / 20

  game_start: ->
    return if @is_start

    @is_start = true
    @game_loop()

  game_loop: ->
    @logic_loop()
    @render_loop()
    @thread = setTimeout (=> @game_loop()), @dt

  logic_loop: ->
    @obstacles_logic()
    @SCORE++
    @hero_logic()

  hero_logic: ->
    if @hero.is_jumping()
      @hero.jumping_time += @dt

      if @hero.jumping_time <= @BASE_JUMP_TIME
        if @hero.jump_far then @hero.charge_time += @dt

        acceleration = 2 * @hero.height / ( @BASE_JUMP_TIME * @BASE_JUMP_TIME )
      else
        if @hero.charge_time <= 150 then @hero.charge_time = 0
        t = @BASE_JUMP_TIME + @hero.charge_time * 1.5
        acceleration = 2 * @hero.height / ( t * t )

      @hero.y = 0.5 * acceleration * (@BASE_JUMP_TIME - @hero.jumping_time) * (@BASE_JUMP_TIME - @hero.jumping_time) + 250 - @hero.height

      jump_frame =  Math.floor @hero.jumping_time / (@BASE_JUMP_TIME * 2 + @hero.charge_time) * 5

      if @JUMP_FRAME != jump_frame
        @hero.tag.attr "src", "/assets/line_skating/jump#{jump_frame}.png"
        @JUMP_FRAME = jump_frame

      if @hero.y >= 250
        @hero.skate()
        @hero.y = 250

        if @is_pressing_f
          @hero.crouch()

  obstacles_logic: ->
    if @run_time >= @ADD_OBSTACLE_INTERVAL
      @add()
      @run_time = 0
    else
      @run_time += @dt

    for obstacle in @obstacles
      # if @check obstacle
        # @gameover()
        # return
      obstacle.x -= @OBSTACLE_MOVE_SPEED
      if obstacle.x + obstacle.width <= 0 then obstacle.need_remove = true
    if @obstacles[0]? && @obstacles[0].need_remove
      rm = @obstacles.splice(0, 1)
      rm[0].tag.remove()

  render_loop: ->
    @render_score()
    @render_hero()
    @render_obstacles()

  render_score: ->
    @score_div.html "SCORE: " + @SCORE

  render_hero: ->
    @setLocation("hero", @hero.x, @hero.y)

  render_obstacles: ->
    for obstacle in @obstacles
      obstacle.tag.css
        left: obstacle.x
        top: obstacle.y

  add: ->
    sort = Math.floor(Math.random() * 2)
    @obstacles.push new Obstacle(sort, @)

  check: (obstacle) ->
    if @hero.is_skating()
      if (obstacle.sort == 0)
        if (obstacle.x > @hero.x && obstacle.x < (@hero.x + @hero.width))
          return true
      else
        if (obstacle.x > (@hero.x + @hero.width * 0.2) && obstacle.x < (@hero.x + @hero.width * 0.8))
          return true
    else if (@hero.is_shelting() && obstacle.sort == 0)
      if (obstacle.x > @hero.x && obstacle.x < (@hero.x + @hero.width))
        return true
    else if @hero.is_jumping() || @hero.is_j_to_s()
      x = @hero_img.getBoundingClientRect().left
      y = @hero_img.getBoundingClientRect().top - @hero.height * 0.2
      if (obstacle.x >= x && obstacle.x <= (x + @hero.width) && obstacle.y >= (y + @hero.height - obstacle.width) && obstacle.y <= (y + @hero.height) || obstacle.x >= (x + @hero.width * 0.2) && obstacle.x <= (x + @hero.width * 0.8) && obstacle.y >= (y + @hero.height - obstacle.width) && obstacle.y <= y)
        return true

  gameover: ->
    # @hero_img.remove()
    # for ( i = start_obstacle i < end_obstacle i++) {
      # obj = document.getElementById("obstacle" + i)
      # @el.removeChild(obj)
    # }

    message = confirm("game over!" + '\n' + "score:" + @SCORE + '\n' + "press confirm to replay")
    if message == true
      return
      # load()

  setLocation: (id, x, y) ->
    obj = document.getElementById(id)
    obj.style.left = x + "px"
    obj.style.top = y + "px"


$ -> new LineSkating(el: $('#line-skating'))