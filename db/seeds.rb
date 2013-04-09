
Dir[File.dirname(__FILE__) + '/../models/*.rb'].each {|file| require file }

User.create!(email: "davidqhr@gmail.com", password: "123456", password_confirmation: "123456")

Game.create!(name: "5-10-K", path: "5-10-K", description: "5-10-K")
Game.create!(name: "Matching Game", path: "matching-game", description: "matching-game")
Game.create!(name: "Hearts", path: "hearts", description: "hearts")