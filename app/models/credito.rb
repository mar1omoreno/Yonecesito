class Credito < ActiveRecord::Base
    # Planes actuales disponibles
    PLANES = [{id: 1, creditos: 3, costo: 45, descripcion_pademobile: "3 créditos por $45 MXP"},
                {id: 2, creditos: 6, costo: 90, descripcion_pademobile: "6 créditos por $90 MXP"}, 
                {id: 3, creditos: 9, costo: 120, descripcion_pademobile: "9 créditos por $120 MXP"}]#, {id: 2, creditos: 9, costo: 120}, {id: 2, creditos: 9, costo: 120}, {id: 2, creditos: 9, costo: 120} ]
    
end
