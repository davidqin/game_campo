class Gobang
  Perfix = "gobang-"

  @@games = {}

  class Player
    attr_accessor :user, :ready, :websocket, :position

    def initialize user, websocket
      self.user      = user
      self.websocket = websocket
      self.ready     = false
    end
  end

  class << self
    def handle user, websocket, custom_string
      player = Player.new(user, websocket)
      game = find_or_create(Gobang::Perfix + custom_string)
      position = game.add(player, websocket)

      websocket.onopen do
        websocket.send JSON(type: :position, position: position)
        puts "#{user.email} JOIN #{game.id}, position: #{position}"
      end

      websocket.onmessage do |msg|
        puts msg
        msg_hash = JSON(msg)
        game.send msg_hash["type"], player, msg_hash
        # EM.next_tick { game.members.each{|s| s.send("a") } }
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

  attr_accessor :id, :player1, :player2, :chess_board, :turn, :status, :winner, :loser

  def initialize id
    self.id = id

    self.turn = 1
    self.chess_board = []

    chess_board_reset
  end

  def add player, websocket
    unless self.player1
      self.player1 = player
      player.position = 1
      return player.position
    end

    unless self.player2
      self.player2 = player
      player.position = 2
      return player.position
    end
  end

  def left player
    if self.player1 == player
      self.player1 = nil
      game_over player2
    end

    if self.player2 == player
      self.player2 = nil
      game_over player1
    end
  end

  def game_over winner
    if winner == player1
      self.winner = player1
      self.loser = player2
    else
      self.winner = player2
      self.loser = player1
    end

    player1.ready = false if player1
    player2.ready = false if player2

    chess_board_reset

    self.winner.websocket.send(JSON(type: :game_over, status: :winner)) if self.winner
    self.loser.websocket.send(JSON(type: :game_over, status: :loser))   if self.loser
  end

  def chess_board_reset
    self.chess_board = []
    15.times do
      c = []
      15.times do
        c << 0
      end
      self.chess_board << c
    end
  end

  def ready player, msg_hash
    player.ready = true

    if player1 and player1.ready and player2 and player2.ready
      puts "#{id} begin!"
      self.player1.websocket.send JSON(type: :game_start)
      self.player2.websocket.send JSON(type: :game_start)
    end
  end

  def cancel_ready player, msg_hash
    player.ready = false
  end

  def put_piece player, msg_hash
    x = msg_hash["x"].to_i - 1
    y = msg_hash["y"].to_i - 1

    chess_board[x][y] = player.position

    # chess_board.each do |a|
    #   puts a.join("-")
    # end

    player1.websocket.send(JSON(type: :put_piece, status: :success, x: msg_hash["x"], y: msg_hash["y"]))
    player2.websocket.send(JSON(type: :put_piece, status: :success, x: msg_hash["x"], y: msg_hash["y"]))
    check_win x, y, player
  end

  def check_win x, y, player
    win = (check_line(x, y,  1, 0) or
          check_line(x, y, -1, 1) or
          check_line(x, y,  0, 1) or
          check_line(x, y,  1, 1))

    if win
      game_over player
    end
  end

  def check_line x, y, dx, dy
    count = 1
    m = chess_board
    v = m[x][y]

    i = 1

    while m[x + dx * i] and v == m[x + dx * i][y + dy * i]
      i += 1;
    end

    count += (i - 1);

    i = 1
    while m[x - dx * i] and v == m[x - dx * i][y - dy * i]
      i += 1;
    end

    count += (i - 1);

    if count >= 5
      return true
    else
      return false
    end
  end
end