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

    @game.bind "game_start",            @remove_players_ready_status
    @game.bind "game_over",             @reset_players_time_bar
    @game.bind "update_member_list",    @update_member_list
    @game.bind "update_players_status", @update_players_status
    @game.bind "update_turn",           @change_turn
    @game.bind "show_chat_message",     @member_speak

    @player1El.html JST['views/no_player']
    @player2El.html JST['views/no_player']

  # no actions

  move: (event) ->
    console.log  $(event.target).parents('.player')

  # event trigger callbacks

  remove_players_ready_status: =>
    @player1El.removeClass("ready")
    @player2El.removeClass("ready")

  reset_players_time_bar: =>
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
      @player1El.addClass("ready")
    else
      @player1El.removeClass("ready")

    if player2
      @player2El.addClass("ready")
    else
      @player2El.removeClass("ready")

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