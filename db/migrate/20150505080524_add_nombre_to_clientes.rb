class AddNombreToClientes < ActiveRecord::Migration
  def change
    add_column :clientes, :nombre, :string
    add_column :clientes, :apellido, :string
  end
end
