class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms, :force => true do |t|
      t.references :game,  null: false
      t.integer :number,   null: false
      t.integer :player_1, null: true
      t.integer :player_2, null: true
      t.string :status,    null: false, default: "truce"
    end

    add_index :rooms, [:game_id, :number], name: :game_room_number, unique: true
  end
end
