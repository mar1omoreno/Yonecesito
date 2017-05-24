class AddCreditosToProfesionistas < ActiveRecord::Migration
  def change
    add_column :profesionistas, :creditos, :integer, :default => 0, :limit => 5
    add_column :profesionistas, :numero_estrellas, :integer, :default => 0, :limit => 6
    add_column :profesionistas, :numero_calificaciones, :integer, :default => 0, :limit => 6
  end
end
