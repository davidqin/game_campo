class GobangController extends Spine.Controller
  events:
    "click #ready":        "get_ready"
    "click #cancel_ready": "cancel_ready"
    # "click .hole":         "put_piece"
    # "click .surrender":    "surrender"

  elements:
    "#ready":        "readyEl"
    "#cancel_ready": "cancel_readyEl"
    "#game_pool":    "game_poolEl"
    "#player1":      "player1El"
    "#player2":      "player2El"

  constructor: ->
    @ws = new WebSocket('ws://' + window.location.host + window.location.pathname)
    super
    @draw_chessboard()

  get_ready: ->
    @ws.send JSON.stringify(type: "get_ready")
    @player1El.css("background", "#0a0")
    @cancel_readyEl.show()
    @readyEl.hide()

  cancel_ready: ->
    @ws.send JSON.stringify(type: "cancel_ready")
    @player1El.css("background", "")
    @cancel_readyEl.hide()
    @readyEl.show()


  draw_chessboard: ->
    list = [1..15]
    html = ""
    html += "<div id=\"gobang\"><table>"
    for num_row in list
      html += "<tr row=#{num_row} class=\"def\">"
      for num_col in list
        html += "<td x=#{num_row} y=#{num_col}></td>"
      html += "</tr>"
    html += "</table></div>"
    # $('#game_pool').html(html).show()
    @game_poolEl.html(html).show()

@GC.controllers.GobangController = GobangController