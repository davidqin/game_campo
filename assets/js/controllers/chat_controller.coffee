class ChatController extends Spine.Controller
  events:
    "submit form#chat": "send_chat_message"

  elements:
    "form#chat input": "chat_inputEl"

  constructor: ->
    super
    @game = @options.game
    @ws   = @options.ws

    @game.bind "show_chat_message", @reset_chat_input

  # actions

  send_chat_message: (event) ->
    event.preventDefault()
    value = $(event.target).find('input').val()
    if value
      @ws.send JSON.stringify(type: "chat", message: value)

  # event trigger callbacks

  reset_chat_input: (message) =>
    @chat_inputEl.val("")

@GC.controllers.ChatController = ChatController