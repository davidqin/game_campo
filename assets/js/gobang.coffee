#= require controllers/gobang_controller

GobangController  = @GC.controllers.GobangController

$ ->
  new GobangController(el: $('body'))
