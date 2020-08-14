class CreateRoutesTable < ActiveRecord::Migration[6.0]
  def change
    create_table :routes do |t|
      t.string :name
      t.string :departure_time
      t.string :arrival_time
    end
  end
end
