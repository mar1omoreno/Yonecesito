class AddIndexToMensajes < ActiveRecord::Migration
  def change
    add_index(:mensajes, [:id_profesionista_evento, :id_profesionista, :id_cliente], name: "mensajes_busqueda_index" )
  end
end
