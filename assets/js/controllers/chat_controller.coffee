class ChatController extends Spine.Controller
  events:
    "submit form#chat": "send_chat_message"

  elements:
    "form#chat input": "chat_inputEl"

  constructor: ->
    super
    @game = @options.game
    @ws   = @options.ws

    @game.bind "show_chat_message", @show_chat_message

  # actions

  send_chat_message: (event) ->
    event.preventDefault()
    value = $(event.target).find('input').val()
    if value
      @ws.send JSON.stringify(type: "chat", message: value)

  # event trigger callbacks

  show_chat_message: (message) =>
    @chat_inputEl.val("")
    console.log message.message + message.position

@GC.controllers.ChatController = ChatController