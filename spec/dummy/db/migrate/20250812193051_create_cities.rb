class CreateCities < ActiveRecord::Migration[8.0]
  def change
    create_table :cities do |t|
      t.string :name

      t.timestamps
    end

    create_join_table :users, :cities do |t|
      t.index [ :user_id, :city_id ]
      t.index [ :city_id, :user_id ]
    end
  end
end
