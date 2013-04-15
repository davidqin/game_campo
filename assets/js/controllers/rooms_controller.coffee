class RoomsController extends Spine.Controller
  constructor: ->
    super

  events:
    "click .room": "click"

  click: (event) ->
    item = jQuery(event.target);
    # alert "click"

  elements:
    ".room": "rooms"

@GC.controllers.RoomsController = RoomsController