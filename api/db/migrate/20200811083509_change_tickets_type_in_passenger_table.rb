class ChangeTicketsTypeInPassengerTable < ActiveRecord::Migration[6.0]
  def change
    remove_column :passengers, :tickets
    add_column :passengers, :tickets, :json
  end
end
