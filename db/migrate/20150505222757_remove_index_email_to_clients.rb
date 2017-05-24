class RemoveIndexEmailToClients < ActiveRecord::Migration
  def change
    # Clientes que entran por facebook sin proveer email requieren de esta implementación
    remove_index :clientes, :email
  end
end
