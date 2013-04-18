
#= require controllers/gobang_controller

GobangController = @GC.controllers.GobangController

$ ->
  a = new GobangController(el: $('body'))
  # ws.onopen = ->
  #   # this.send "ask_position"

  # resetGamePool = ->
  #   list = [1..15]
  #   html = ""
  #   html += "<table>"
  #   for num_row in list
  #     html += "<tr row=#{num_row} class=\"def\">"
  #     for num_col in list
  #       html += "<td x=#{num_row} y=#{num_col}></td>"
  #     html += "</tr>"
  #   html += "</table>"

  #   # $("#gamepool").html(html).show()

  # # resetGamePool()

  # i = 15

  # gameStart = (data) ->
  #   $("td").bind "click", ->
  #     x = $(this).attr "x"
  #     y = $(this).attr "y"
  #     ws.send JSON.stringify(type: 'PutPieceRequest', x:x, y:y)

  #   ws.onmessage = (m)->
  #     if m.data == "a"
  #       $("td[x=#{i}][y=#{i}]").css "background-image", "url(/assets/gobang/black.png)"
  #       i -= 1

  # # gameStart()





