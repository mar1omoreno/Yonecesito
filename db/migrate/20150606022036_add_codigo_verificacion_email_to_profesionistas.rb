class AddCodigoVerificacionEmailToProfesionistas < ActiveRecord::Migration
  def change
    add_column :profesionistas, :codigo_verificacion_email, :string, :limit => 50
  end
end
