class Room < ActiveRecord::Base
  Truce = "truce"

  belongs_to :game
end