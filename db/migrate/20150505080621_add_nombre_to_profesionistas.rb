class AddNombreToProfesionistas < ActiveRecord::Migration
  def change
    add_column :profesionistas, :nombre, :string
    add_column :profesionistas, :apellido, :string
  end
end
