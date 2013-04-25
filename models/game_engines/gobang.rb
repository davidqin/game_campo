class Gobang

  Perfix = "gobang-"

  @@games = {}

  class << self
    def handle user, websocket, custom_string
      player = Player.new(user, websocket)
      game   = find_or_create(Gobang::Perfix + custom_string)

      if game.has_player?(player)

        websocket.onopen do
          websocket.send JSON(type: :error, message: "You are already in this room somewhere else, the websocket is closing.")
          EM.add_periodic_timer(5) { websocket.close_connection }
        end

        websocket.onclose do
          puts "#{player.email} websocket close because multi connections!"
        end

        return
      end

      websocket.onopen do
        game.enter(player)
        puts "#{user.email} JOIN #{game.id}"
      end

      websocket.onmessage do |msg|
        puts "#{player.email}:  #{msg}"
        msg_hash = JSON(msg)
        game.send "#{msg_hash["type"]}", player, msg_hash
      end

      websocket.onclose do
        game.left(player)
        puts "#{user.email} LEFT #{game.id}"
      end
    end

    def find_or_create id
      if @@games[id]
        @@games[id]
      else
        @@games[id] = new(id)
      end
    end
  end

  attr_accessor :id, :player1, :player2, :watchers, :chess_board, :turn, :is_start, :timer

  def initialize id
    self.id          = id
    self.watchers    = []
  end

  def has_player? player
    if self.player1 == player or self.player2 == player
      return true
    end

    self.watchers.each do |watcher|
      return true if watcher == player
    end

    false
  end

  def enter player
    if not self.player1
      add_player player, :player1
    elsif not self.player2
      add_player player, :player2
    else
      add_player player, :watcher
    end

    broadcast_member_list
  end

  def left player
    remove_player player
    broadcast_member_list
  end

  def add_player player, player_type
    case player_type
    when :player1
      self.player1 = player
      player.position = 1
    when :player2
      self.player2 = player
      player.position = 2
    when :watcher
      self.watchers << player
      player.position = -1
    end
  end

  def remove_player player
    if self.player1 == player
      self.player1 = nil
      game_over player2, "#{player.email} LEFT the Room!" if self.is_start
      return
    end

    if self.player2 == player
      self.player2 = nil
      game_over player1, "#{player.email} LEFT the Room!" if self.is_start
      return
    end

    watchers.delete player
  end

  def ready player, msg_hash
    return if self.is_start
    return if player.is_ready
    return if player.position == -1

    player.is_ready = true

    player.send type: :ready_success

    broadcast_players_status

    game_start if player1.try(:is_ready) and player2.try(:is_ready)
  end

  def cancel_ready player, msg_hash
    return if self.is_start
    return unless player.is_ready
    return if player.position == -1

    player.is_ready = false
    player.send type: :cancel_ready_success

    broadcast_players_status
  end

  def chat player, msg_hash
    return if player.position == -1

    broadcast type: :show_chat_message, message: msg_hash["message"], position: player.position
  end

  def move player, msg_hash
    return if self.is_start

    target = msg_hash["target"]
    destination_player = send(target)

    return if destination_player

    remove_player player
    add_player    player, target.to_sym

    broadcast_member_list
    broadcast_players_status
  end

  def put_piece player, msg_hash
    return unless self.is_start
    return unless player == turn

    x = msg_hash["x"].to_i - 1
    y = msg_hash["y"].to_i - 1

    return if chess_board[x][y] != 0

    chess_board[x][y] = player.position

    color = player.position == 1 ? "black" : "white"

    broadcast type: :update_chessboard, x: msg_hash["x"], y: msg_hash["y"], color: color

    check_win x, y, player

    change_turn
  end

  def game_start
    self.is_start = true
    self.turn     = player1
    chess_board_reset
    broadcast type: :game_start
    reset_time_left
    broadcast_turn
    puts "#{id} begin!"
  end

  def reset_time_left
    winner = self.turn == player1 ? player2 : player1
    EM.cancel_timer(self.timer)
    self.timer = EM.add_timer(30) { game_over winner }
  end

  def game_over winner, message = nil
    EM.cancel_timer(self.timer)

    loser = winner == player1 ? player2 : player1

    winner.send type: :game_over, result: :winner, message: message if winner
    loser.send  type: :game_over, result: :loser,  message: message if loser

    message_for_watchers = message.nil? ? "Winner is #{winner.email}" : message

    broadcast_watchers type: :game_over, message: message_for_watchers

    player1.is_ready = false if player1
    player2.is_ready = false if player2

    self.is_start = false

    broadcast_players_status
  end

  def chess_board_reset
    self.chess_board = []
    15.times do
      c = []
      15.times { c << 0 }
      self.chess_board << c
    end
  end

  def change_turn
    return unless self.is_start

    self.turn = self.turn == player1 ? player2 : player1
    broadcast_turn
    reset_time_left
  end

  def broadcast_turn
    broadcast type: :update_turn, turn: self.turn.position
  end

  def broadcast msg_hash
    EM.next_tick do
      player1.send(msg_hash) if player1
      player2.send(msg_hash) if player2
      watchers.each { |watcher| watcher.send(msg_hash) }
    end
  end

  def broadcast_watchers msg_hash
    EM.next_tick do
      watchers.each { |watcher| watcher.send(msg_hash) }
    end
  end

  def broadcast_players_status
    broadcast type: :update_players_status, player1: player1.try(:is_ready), player2: player2.try(:is_ready)
  end

  def broadcast_member_list
    broadcast type: :update_member_list, members: {
      player1: player1.try(:email),
      player2: player2.try(:email),
      watchers: watchers.map{ |watcher| watcher.email }
    }
  end

  def check_win x, y, player
    win = (check_line(x, y,  1, 0) or
           check_line(x, y, -1, 1) or
           check_line(x, y,  0, 1) or
           check_line(x, y,  1, 1))

    game_over player if win
  end

  def check_line x, y, dx, dy
    count = 1
    m = chess_board
    v = m[x][y]

    i = 1
    i += 1 while m[x + dx * i] and v == m[x + dx * i][y + dy * i]

    count += (i - 1);

    i = 1
    i += 1 while m[x - dx * i] and v == m[x - dx * i][y - dy * i]

    count += (i - 1);

    count >= 5 ? true : false
  end
end