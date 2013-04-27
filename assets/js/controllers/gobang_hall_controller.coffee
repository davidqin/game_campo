class GobangHallController extends Spine.Controller
  constructor: ->
    super

    @ws = new WebSocket('ws://' + window.location.host + window.location.pathname)

    @bind "a_game_start",           @a_game_start
    @bind "a_game_over",            @a_game_over

    @bind "a_player_enter_a_game",  @a_player_enter_a_game
    @bind "a_player_left_a_game",   @a_player_left_a_game

    @ws.onmessage = (msg_string) =>
      options = JSON.parse(msg_string.data)
      order   = options.type
      console.log order
      @trigger(order, options)

  a_game_start: (options) ->
    game_id = options.game_id
    gameEl  = @el.find("[data-game-id=#{game_id}]")
    gameEl.find('img').attr('src', '/assets/fighting.jpg')

  a_game_over: (options) ->
    game_id = options.game_id
    gameEl  = @el.find("[data-game-id=#{game_id}]")
    gameEl.find('img').attr('src', '/assets/waiting.png')

  a_player_enter_a_game: (options) ->
    game_id = options.game_id
    player  = options.player

    gameEl  = @el.find("[data-game-id=#{game_id}]")
    gameEl.find(".player#{player.position}").html player.email

  a_player_left_a_game: (options) ->
    game_id = options.game_id
    player  = options.player

    gameEl  = @el.find("[data-game-id=#{game_id}]")
    gameEl.find(".player#{player.position}").html "Empty"

$ -> new GobangHallController(el: $('#games'))