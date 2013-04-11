#= require models/room
#= require controllers/rooms_controller

Room = @GC.models.Room
RoomsController = @GC.controllers.RoomsController

class Hall extends Spine.Controller
  constructor: ->
    alert "work!!"


$ ->
  new Hall(el: $('body'))