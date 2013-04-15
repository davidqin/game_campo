class Channel

  # @@channels = {
  #   "-game-matching-game" => [ws1, ws2, ws3]
  # }
  @@channels = {}

  class << self
    private :new

    def find_or_create path
      id = parse_channel_id(path)

      if @@channels[id]
        @@channels[id]
      else
        @@channels[id] = new(id)
      end
    end

    def parse_channel_id path
      path.gsub('/', '-')
    end
  end


  attr_accessor :id, :members

  def initialize id
    self.id = id
    self.members = []
  end

  def add websocket
    self.members << websocket
  end

  def del websocket
    self.members.delete_if do |ws|
      ws == websocket
    end
  end
end