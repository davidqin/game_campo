class CreateGames < ActiveRecord::Migration

  def change
    create_table :games, force: true do |t|
      t.string   :name, null: false, limit: 128
      t.string   :path, null: false
      t.text     :description, null: false
      t.timestamps
    end
  end

end
