#= require controllers/players_controller
#= require controllers/chat_controller

#= require views/game_over

PlayersController = @GC.controllers.PlayersController
ChatController    = @GC.controllers.ChatController

class GobangController extends Spine.Controller

  events:
    "click #ready":         "ready"
    "click #cancel_ready":  "cancel_ready"
    "click .hole":          "put_piece"
    "touchend .hole":       "put_piece"

  elements:
    "#ready":               "readyEl"
    "#cancel_ready":        "cancel_readyEl"
    "#game_pool":           "game_poolEl"

  constructor: ->
    super

    @game_is_start = false
    @draw_chessboard()

    @bind "game_start",           @game_start
    @bind "game_over",            @game_over
    @bind "ready_success",        @ready_success
    @bind "cancel_ready_success", @cancel_ready_success
    @bind "update_chessboard",    @update_chessboard
    @bind "error",                (options) -> alert options.message

    @ws = new WebSocket('ws://' + window.location.host + window.location.pathname)

    new PlayersController el: $('.span4'), game: @, ws: @ws
    new ChatController    el: $('.span4'), game: @, ws: @ws

    @ws.onmessage = (msg_string) =>
      options = JSON.parse(msg_string.data)
      order   = options.type
      console.log order
      @trigger(order, options)

  # actions

  ready: ->
    @ws.send JSON.stringify(type: "ready")

  cancel_ready: ->
    @ws.send JSON.stringify(type: "cancel_ready")

  put_piece: (event) ->
    return unless @game_is_start

    hole =  $(event.target)
    @ws.send JSON.stringify {type: "put_piece", x: hole.attr("x"), y: hole.attr("y")}

  # event trigger callbacks

  update_chessboard: (message) ->
    x = message.x
    y = message.y
    $(".hole[x=#{x}][y=#{y}]").addClass(message.color).removeClass("hole")

  game_start: ->
    @game_is_start = true
    $('td').removeClass("white").removeClass("black").removeClass("hole").addClass("hole")

  game_over: (message) ->
    result = message.result
    message = message.message

    $('body').append(JST['views/game_over'](result: result, message: message))
    $('#game_over_modal').modal("show").on 'hidden', -> $(@).remove()

    @game_is_start = false
    @cancel_readyEl.hide()
    @readyEl.show()

  ready_success: ->
    @cancel_readyEl.show()
    @readyEl.hide()

  cancel_ready_success: ->
    @cancel_readyEl.hide()
    @readyEl.show()

  # private

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