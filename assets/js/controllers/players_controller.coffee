#= require models/player


class PlayersController extends Spine.Controller
  elements:
    '#player1': 'player1El'
    '#player2': 'player2El'

  # events:
  #   'keyup input': 'filter'
  #   'click footer button': 'create'

  constructor: ->
    super
    @player1El.html JST['views/no_player']
    @player2El.html JST['views/no_player']



  # render: =>
  #   contacts = Contact.filter(@query)
  #   @list.render(contacts)

  # change: (item) =>
  #   @navigate '/contacts', item.id

  # create: ->
  #   item = Contact.create()
  #   @navigate('/contacts', item.id, 'edit')

@GC.controllers.PlayersController = PlayersController