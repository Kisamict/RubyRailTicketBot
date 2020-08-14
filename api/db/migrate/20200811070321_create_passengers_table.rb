class CreatePassengersTable < ActiveRecord::Migration[6.0]
  def change
    create_table :passengers do |t|
      t.string :first_name
      t.string :last_name
      t.string :birth_date
      t.string :passport_id
      t.string :tickets
    end
  end
end
