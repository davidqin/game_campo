#= require views/player
#= require views/no_player
#= require views/watchers

PlayersController  = @GC.controllers.PlayersController

class GobangController extends Spine.Controller
  events:
    "click #ready":         "ready"
    "click #cancel_ready":  "cancel_ready"
    "click .hole":          "put_piece"
    "touchend .hole":       "put_piece"
    "submit form#chat":     "send_chat_message"

  elements:
    "#ready":        "readyEl"
    "#cancel_ready": "cancel_readyEl"
    "#game_pool":    "game_poolEl"
    "#player1":      "player1El"
    "#player2":      "player2El"
    "#watchers":     "watchersEl"

  constructor: ->
    super
    # @players_controller = new PlayersController(el: $('.span3'))
    @game_is_start = false
    @draw_chessboard()
    @ws = new WebSocket('ws://' + window.location.host + window.location.pathname)
    @player1El.html JST['views/no_player']
    @player2El.html JST['views/no_player']

    @order_set =
      "set_position":          @set_position
      "game_start":            @game_start
      "game_over":             @game_over
      "ready_success":         @ready_success
      "cancel_ready_success":  @cancel_ready_success
      "member_list":           @member_list
      "players_status":        @players_status
      "put_piece":             @update_chessboard
      "update_turn":           @update_turn
      "chat_message":          @show_chat_message
      "error":                 (options) -> alert options.message

    @ws.onmessage = (msg_string) =>
      options = JSON.parse(msg_string.data)
      func    = @order_set[options.type]
      func.call(@, options)

  players_status: (message) ->
    if message.player1
      @player1El.addClass("ready")
    else
      @player1El.removeClass("ready")

    if message.player2
      @player2El.addClass("ready")
    else
      @player2El.removeClass("ready")

  update_chessboard: (message) ->
    x = message.x
    y = message.y
    $(".hole[x=#{x}][y=#{y}]").addClass(if @turn == 1 then "black" else "white").removeClass("hole")

  ready_success: ->
    @cancel_readyEl.show()
    @readyEl.hide()

  cancel_ready_success: ->
    @cancel_readyEl.hide()
    @readyEl.show()

  set_position: (message) ->
    @position = message.position
    if @position == 1
      @myself   = @player1El
      @opponent = @player2El
    else if @position == 2
      @myself   = @player2El
      @opponent = @player1El
    else if @position == -1
      @readyEl.addClass("disabled")
      @cancel_readyEl.addClass("disabled")

  member_list: (message) ->
    members = message.members

    player1 = members.player1
    player2 = members.player2
    watchers = members.watchers

    if player1
      @player1El.html JST['views/player'](email: player1)
    else
      @player1El.html JST['views/no_player']

    if player2
      @player2El.html JST['views/player'](email: player2) if player2
    else
      @player2El.html JST['views/no_player']

    @watchersEl.html JST['views/watchers'](watchers: watchers)

  update_turn: (message) ->
    @turn = message.turn
    if @turn == 2
      @player1El.find('.bar').removeClass("turn").css('width', "100%").css('background-color', "")
      @player2El.find('.bar').addClass("turn").css('width', 0).css('background-color', "red")
    else if @turn == 1
      @player2El.find('.bar').removeClass("turn").css('width', "100%").css('background-color', "")
      @player1El.find('.bar').addClass("turn").css('width', 0).css('background-color', "red")

  game_start: ->
    @game_is_start = true
    @player1El.removeClass("ready")
    @player2El.removeClass("ready")
    @reset_game()

  reset_game: ->
    $('td').removeClass("white").removeClass("black").removeClass("hole").addClass("hole")

  game_over: (message) ->
    alert "game_over, winner is #{message.winner}"
    @game_is_start = false
    @player1El.find('.bar').removeClass("turn").css('width', "100%").css('background-color', "")
    @player2El.find('.bar').removeClass("turn").css('width', "100%").css('background-color', "")
    @cancel_readyEl.hide()
    @readyEl.show()

  ready: ->
    @ws.send JSON.stringify(type: "ready")

  cancel_ready: ->
    @ws.send JSON.stringify(type: "cancel_ready")

  put_piece: (event) ->
    return unless @game_is_start
    return unless @my_turn()

    hole =  $(event.target)
    @ws.send JSON.stringify {type: "put_piece", x: hole.attr("x"), y: hole.attr("y")}

  send_chat_message: (event) ->
    event.preventDefault()
    value = $(event.target).find('input').val()
    if value
      @ws.send JSON.stringify(type: "chat", message: value)

  show_chat_message: (message) ->
    $('#chat input').val("")
    console.log message.message + message.position

  my_turn: ->
    @turn == @position

  draw_chessboard: ->
    list = [1..15]
    html = ""
    html += "<div id=\"gobang\"><table>"
    for num_row in list
      html += "<tr row=#{num_row} class=\"def\">"
      for num_col in list
        html += "<td x=#{num_row} y=#{num_col} class=\"hole\"></td>"
      html += "</tr>"
    html += "</table></div>"
    @game_poolEl.html(html).show()

@GC.controllers.GobangController = GobangController