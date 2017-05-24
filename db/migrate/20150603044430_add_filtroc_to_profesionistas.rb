class AddFiltrocToProfesionistas < ActiveRecord::Migration
  def change
    add_column :profesionistas, :tel_fijo, :string
    add_column :profesionistas, :tel_celular, :string
    add_column :profesionistas, :empresa, :string
  end
end
