class AddFechaAltaToEventos < ActiveRecord::Migration
  def change
    add_column :eventos, :fecha_alta, :date
  end
end
