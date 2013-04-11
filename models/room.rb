class Room < ActiveRecord::Base
  Truce = "truce"

  belongs_to :game
  belongs_to :player_1, class_name: "User"
  belongs_to :player_2, class_name: "User"

  def set_player_1= user
    self.player_1 = user
    self.save!
  end
end