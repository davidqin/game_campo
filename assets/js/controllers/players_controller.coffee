#= require views/player
#= require views/no_player
#= require views/watchers

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
    @game.bind "game_over",             @reset_players_time_bar
    @game.bind "update_member_list",    @update_member_list
    @game.bind "update_players_status", @update_players_status
    @game.bind "update_turn",           @change_turn
    @game.bind "show_chat_message",     @member_speak

    @player1El.html JST['views/no_player']
    @player2El.html JST['views/no_player']

  # no actions

  move: (event) ->
    @ws.send JSON.stringify type: "move", target: $(event.target).parents('.player').data('player')

  # event trigger callbacks

  game_start: =>
    @player1El.find('.label').removeClass("label-success").addClass("label-important").html("Fighting!")
    @player2El.find('.label').removeClass("label-success").addClass("label-important").html("Fighting!")

  reset_players_time_bar: =>
    @player1El.find('.label').removeClass("label-important")
    @player2El.find('.label').removeClass("label-important")

    @player1El.find('.bar').removeClass("turn").css('width', "100%").css('background-color', "")
    @player2El.find('.bar').removeClass("turn").css('width', "100%").css('background-color', "")

  update_member_list: (options) =>
    members = options.members

    player1  = members.player1
    player2  = members.player2
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
      @player2El.find('.bar').addClass("turn").css('width', 0).css('background-color', "red")
    else if turn == 1
      @player2El.find('.bar').removeClass("turn").css('width', "100%").css('background-color', "")
      @player1El.find('.bar').addClass("turn").css('width', 0).css('background-color', "red")

  member_speak: (options) =>
    position = options.position
    player = @["player#{position}El"]

    clear_popover = =>
      player.find('img').popover('destroy')
      clearTimeout(player.data("time-out"))

    clear_popover()

    player.find('img').popover
      trigger: "manual"
      content: options.message
      placement: 'bottom'

    player.find('img').popover("show")
    player.data "time-out", (setTimeout clear_popover, 3000)


@GC.controllers.PlayersController = PlayersController