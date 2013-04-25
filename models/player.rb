class Player
  attr_accessor :user, :is_ready, :websocket, :position

  def initialize user, websocket
    self.user      = user
    self.websocket = websocket
    self.is_ready  = false
  end

  def == player
    if self.nil?
      return false
    end

    if player.nil?
      return false
    end

    self.user == player.user
  end

  def email
    user.email
  end

  def send msg_hash
    EM.next_tick do
      websocket.send JSON(msg_hash)
    end
  end
end