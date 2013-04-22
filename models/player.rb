class Player
  attr_accessor :user, :is_ready, :websocket, :position

  def initialize user, websocket
    self.user      = user
    self.websocket = websocket
    self.is_ready  = false
  end

  def email
    user.email
  end

  def send msg_hash
    websocket.send JSON(msg_hash)
  end
end