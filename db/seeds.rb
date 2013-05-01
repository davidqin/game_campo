User.create!(email: "davidqhr@gmail.com", password: "123456", password_confirmation: "123456")
User.create!(email: "a@a.com", password: "asdfasdf", password_confirmation: "asdfasdf")
User.create!(email: "b@b.com", password: "asdfasdf", password_confirmation: "asdfasdf")

Game.create!(name: "Gobang", path: "gobang", description: "gobang")
Game.create!(name: "LineSkating", path: "line_skating", description: "lineskating")