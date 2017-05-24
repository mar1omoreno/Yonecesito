class AddIdCiudadToClientes < ActiveRecord::Migration
  def change
    add_column :clientes, :id_ciudad_republica, :integer
  end
end
