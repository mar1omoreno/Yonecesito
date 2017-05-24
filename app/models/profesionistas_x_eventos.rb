class ProfesionistasXEventos < ActiveRecord::Base
    ESTADO_PENDIENTE = 0
    ESTADO_CONTRATADO_SIN_EVALUAR = 1
    ESTADO_CONTRATADO_EVALUADO = 2
    ESTADO_RECHAZADO_SIN_EVALUAR = 3
    ESTADO_RECHAZADO_EVALUADO = 4
    
    def self.get_valor_estado(estado)
        if estado == ESTADO_PENDIENTE
            return "Pendiente"
        elsif estado == ESTADO_CONTRATADO_SIN_EVALUAR
            return "Contratado sin evaluar"
        elsif estado == ESTADO_CONTRATADO_EVALUADO
            return "Contratado evaluado"
        elsif estado == ESTADO_RECHAZADO_SIN_EVALUAR
            return "Rechazado sin evaluar"
        elsif estado == ESTADO_RECHAZADO_EVALUADO
            return "Rechazado evaluado"
        else
            return "Estado desconocido"
        end
    end
    
    
    
    #rechazo profesionista x evento
    EL_PRESUPUESTO_ES_DEMACIADO_CARO = 1
    NO_ES_LO_QUE_NECESITABA = 2
    EL_PROFECIONAL_SE_ENCUENTRA_MUY_LEJOS = 3
    NO_RECIBI_UN_TRATO_CORDIAL = 4
    NO_ME_DA_CONFIANZA = 5
    OTRO_MOTIVO = 6
    
    RECHAZADO = [{id: EL_PRESUPUESTO_ES_DEMACIADO_CARO , valor: "EL presupuesto es demaciado caro"},
                 {id: NO_ES_LO_QUE_NECESITABA , valor: "No es lo que necesitaba"},
                 {id: EL_PROFECIONAL_SE_ENCUENTRA_MUY_LEJOS, valor: "El profesional se encuentra muy lejos"},
                 {id: NO_RECIBI_UN_TRATO_CORDIAL, valor: "No recibí un trato cordial."},
                 {id: NO_ME_DA_CONFIANZA, valor: "No me da confianza, quisiera que el equipo de Yo Necesito investigará a este profesional."},
                 {id: OTRO_MOTIVO, valor: "Otro motivo."}]
    
    # Devuelve el valor texto del id de RECHAZADO indicado
    # Uso: Evento::get_rechazado_estado(Evento::EN_ESPERA)
    def self.get_rechazado_estado(id)
        hash = RECHAZADO.detect {|u| u[:id] == id } 
        return hash[:valor]
    end
    #Devuelve el id del valor para params
    def self.get_id_rechazado(valor)
        hash = RECHAZADO.detect {|u| u[:valor] == valor } 
        return hash[:id]
    end
    
    
    
    
end
