class AddIdCiudadToProfesionistas < ActiveRecord::Migration
  def change
    add_column :profesionistas, :id_ciudad_republica, :integer
  end
end
