class Game < ActiveRecord::Base
  has_many :rooms

  after_create :create_rooms

  def create_rooms
    12.times do |num|
      self.rooms.create!(number: num + 1)
    end
  end

  def style_name
    path
  end
end