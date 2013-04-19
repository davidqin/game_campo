class GobangController extends Spine.Controller
  events:
    "click #ready":         "ready"
    "click #cancel_ready":  "cancel_ready"
    "click .hole":          "put_piece"

  elements:
    "#ready":        "readyEl"
    "#cancel_ready": "cancel_readyEl"
    "#game_pool":    "game_poolEl"
    "#player1":      "player1El"
    "#player2":      "player2El"
    "#watchers":     "watchersEl"

  constructor: ->
    super
    @game_start = false
    @draw_chessboard()
    @ws = new WebSocket('ws://' + window.location.host + window.location.pathname)

    @ws.onmessage = (message) =>
      message = JSON.parse(message.data)
      if message.type && message.type == "set_position"
        @set_position message
      else if message.type && message.type == "game_start"
        @game_begin()
      else if message.type && message.type == "member_list"
        @member_list message
      else if message.type && message.type == "players_status"
        @players_status message
      else if message.type && message.type == "put_piece" && message.status == "success"
        $(".hole[x=#{message.x}][y=#{message.y}]").addClass(if @turn == 1 then "black" else "white").removeClass("hole")
        @change_turn()
      else if message.type && message.type == "put_piece" && message.status == "failed"
        alert "put piece failed"
      else if message.type && message.type == "game_over"
        @game_over message

  players_status: (message) ->
    if message.player1
      @player1El.addClass("ready")
    else
      @player1El.removeClass("ready")

    if message.player2
      @player2El.addClass("ready")
    else
      @player2El.removeClass("ready")

  set_position: (message) ->
    @position = message.position
    if @position == 1
      @myself   = @player1El
      @opponent = @player2El
      @player1El.addClass('myself')
    else if @position == 2
      @myself   = @player2El
      @opponent = @player1El
      @player2El.addClass('myself')
    else if @position == -1
      @readyEl.addClass("disabled")
      @cancel_readyEl.addClass("disabled")


  member_list: (message) ->
    members = message.members

    player1 = members.player1
    player2 = members.player2
    watchers = members.watchers

    @player1El.html player1
    @player2El.html player2
    html = ""

    for watcher in watchers
      html += watcher
    @watchersEl.html html


  change_turn: ->
    if @turn == 1
      @player1El.removeClass("turn")
      @player2El.addClass("turn")
      @turn = 2

    else if @turn == 2
      @player1El.addClass("turn")
      @player2El.removeClass("turn")
      @turn = 1

  game_begin: ->
    @game_start = true
    @turn = 1
    @player1El.removeClass("ready")
    @player2El.removeClass("ready")
    @player1El.addClass("turn")
    @reset_game()

  reset_game: ->
    $('td').removeClass("white").removeClass("black").removeClass("hole").addClass("hole")

  game_over: (message) ->
    alert "game_over, winner is #{message.winner}"
    @game_start = false
    @player1El.removeClass("turn")
    @player2El.removeClass("turn")
    @cancel_readyEl.hide()
    @readyEl.show()


  ready: ->
    @ws.send JSON.stringify(type: "ready")
    @cancel_readyEl.show()
    @readyEl.hide()

  cancel_ready: ->
    @ws.send JSON.stringify(type: "cancel_ready")
    @myself.css("background", "")
    @cancel_readyEl.hide()
    @readyEl.show()

  put_piece: (event) ->
    return unless @game_start
    return unless @my_turn()
    hole =  $(event.target)
    @ws.send JSON.stringify {type: "put_piece", x: hole.attr("x"), y: hole.attr("y")}

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