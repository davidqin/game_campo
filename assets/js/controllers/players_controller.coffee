#= require views/player
#= require views/no_player

class PlayersController extends Spine.Controller
  elements:
    '#player1':   'player1El'
    '#player2':   'player2El'
    '#watchers':  'watchersEl'

  events:
    'click .move-here': 'move'

  constructor: ->
    super

    @game = @options.game
    @ws   = @options.ws

    @game.bind "game_start",            @game_start
    @game.bind "game_over",             @reset_players
    @game.bind "update_players_status", @update_players_status
    @game.bind "update_turn",           @change_turn
    @game.bind "show_chat_message",     @member_speak

    @game.bind "add_player",            @add_player
    @game.bind "remove_player",         @remove_player
    @game.bind "add_watcher",           @add_watcher
    @game.bind "remove_watcher",        @remove_watcher

    @player1El.html JST['views/no_player'] message: "Player1"
    @player2El.html JST['views/no_player'] message: "Player2"

  # no actions

  move: (event) ->
    @ws.send JSON.stringify type: "move", target: $(event.target).parents('.player').data('player')

  # event trigger callbacks

  game_start: =>
    @player1El.find('.label').removeClass("label-success").addClass("label-important").html("Fighting!")
    @player2El.find('.label').removeClass("label-success").addClass("label-important").html("Fighting!")

  reset_players: =>
    @player1El.find('.label').removeClass("label-important")
    @player2El.find('.label').removeClass("label-important")

    @player1El.find('.bar').removeClass("turn").css('width', "100%").css('background-color', "")
    @player2El.find('.bar').removeClass("turn").css('width', "100%").css('background-color', "")

    @player1El.find('.status .label-info').remove()
    @player2El.find('.status .label-info').remove()

  update_players_status: (options) =>
    player1 = options.player1
    player2 = options.player2

    if player1
      @player1El.find('.label').addClass("label-success").html("Ready")
    else
      @player1El.find('.label').removeClass("label-success").html("Not Ready")

    if player2
      @player2El.find('.label').addClass("label-success").html("Ready")
    else
      @player2El.find('.label').removeClass("label-success").html("Not Ready")

  change_turn: (options) =>
    turn = options.turn
    if turn == 2
      @player1El.find('.bar').removeClass("turn").css('width', "100%").css('background-color', "")
      @player1El.find('.status .label-info').remove()


      @player2El.find('.bar').addClass("turn").css('width', 0).css('background-color', "red")
      @player2El.find('.status').append('<span class="label label-info">MyTurn</span>')
    else if turn == 1
      @player2El.find('.bar').removeClass("turn").css('width', "100%").css('background-color', "")
      @player2El.find('.status .label-info').remove()

      @player1El.find('.bar').addClass("turn").css('width', 0).css('background-color', "red")
      @player1El.find('.status').append('<span class="label label-info">MyTurn</span>')

  member_speak: (options) =>
    position = options.position
    player = @["player#{position}El"]

    clear_popover = =>
      player.find('img').tooltip('destroy')
      clearTimeout(player.data("time-out"))

    clear_popover()

    player.find('img').tooltip
      trigger: "manual"
      title: options.message
      placement: 'bottom'

    player.find('img').tooltip("show")
    player.data "time-out", (setTimeout clear_popover, 3000)

  add_player: (options) =>
    player = options.player
    playerEl = @["player#{player.position}El"]
    playerEl.html JST['views/player'](player: player)

  remove_player: (options) =>
    player = options.player
    playerEl = @["player#{player.position}El"]
    playerEl.html JST['views/no_player'] message: "Player#{player.position}"

  add_watcher: (options) =>
    watcher = options.watcher

    watcherEl = @watchersEl.find("p[data-email='#{watcher.email}']")

    if watcherEl.size() == 0
      @watchersEl.append("<p data-email=\"#{watcher.email}\">#{watcher.email}</p>")
      if @watchersEl.children().size() > 0
        @watchersEl.addClass('well')

  remove_watcher: (options) =>
    watcher = options.watcher
    @watchersEl.find("p[data-email='#{watcher.email}']").remove()

    if @watchersEl.children().size() == 0
        @watchersEl.removeClass('well')

@GC.controllers.PlayersController = PlayersController