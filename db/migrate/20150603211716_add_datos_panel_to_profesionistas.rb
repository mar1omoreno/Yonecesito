class AddDatosPanelToProfesionistas < ActiveRecord::Migration
  def change
    add_column :profesionistas, :sobre_empresa, :string, :limit => 300
    add_column :profesionistas, :fecha_nacimiento, :date
    add_column :profesionistas, :sexo, :string, :limit => 1
    add_column :profesionistas, :pagina_web, :string, :limit => 70
    add_column :profesionistas, :direccion, :string, :limit => 100
    add_column :profesionistas, :cp, :string, :limit => 5
    add_column :profesionistas, :email_verificado, :integer, :limit => 1
  end
end
