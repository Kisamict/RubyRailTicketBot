class CreateTicketsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :tickets do |t|
      t.string :first_name
      t.string :last_name
      t.string :route_name
      t.string :departure_time
      t.string :arrival_time
    end
  end
end
