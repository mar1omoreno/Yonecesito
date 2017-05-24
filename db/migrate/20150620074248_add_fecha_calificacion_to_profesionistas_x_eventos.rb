class AddFechaCalificacionToProfesionistasXEventos < ActiveRecord::Migration
  def change
    add_column :profesionistas_x_eventos, :fecha_calificacion, :datetime
  end
end
