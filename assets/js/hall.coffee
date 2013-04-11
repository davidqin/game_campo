#= require models/room
#= require controllers/rooms_controller

Room = @GC.models.Room
RoomsController = @GC.controllers.RoomsController

class Hall extends Spine.Controller
  elements:
    "#rooms": "roomsEl"

  constructor: ->
    super
    @rooms = new RoomsController(el: @roomsEl)

    # alert("works!")

$ ->
  new Hall(el: $('body'))