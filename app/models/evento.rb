class Evento < ActiveRecord::Base

    COSTO_CREDITOS_APLICAR = 1 # Indica el costo en créditos que tiene para un profesionista el aplicar a un evento

    # Helper para enlistadores como en formulario select()
    # Evento::URGENCIAS.collect{|u| [u[:valor], u[:id] ]} 
    # Para conseguir un hash por id se usa
    # hash = URGENCIAS.detect {|u| u[:id] == 3 } 
    # hash[:valor] #devuelve 'No urgente'
    URGENCIAS = [{id: 1, valor: 'Urgente'}, {id:2, valor: 'Medianamente urgente'}, {id:3, valor: 'No urgente'} ] 

    PENDIENTE = "Pendiente"
    TERMINADO = "Terminado"
    EVALUADO = "Evaluado"
    
    ESTATUS_PENDIENTE = 1
    ESTATUS_TERMINADO = 2
    ESTATUS_EVALUADO = 3
    
    ##1 Pendiente (al insertar registro)\n2 Terminado (al cumplirse la fecha del evento)\n3 Evaluado (al evaluar el evento)
    ESTATUS = [{id: ESTATUS_PENDIENTE, valor: PENDIENTE}, {id: ESTATUS_TERMINADO, valor: TERMINADO},{id: ESTATUS_EVALUADO, valor: EVALUADO}]
    
    # Para usar en consultas de forma Evento.where( estatus: Evento::get_id_estatus(Evento::TERMINADO) )
    def self.get_id_estatus(valor)
        hash = ESTATUS.detect {|u| u[:valor] == valor } 
        return hash[:id]
    end
    
    
    # Función llamada por Cron mediante gema Whenever "config/schedule.rb" para actualizar estatus de eventos 
    def self.actualizar_estatus
        puts "#{Time.zone.now} INICIA actualizar_estatus"
        # Actualiza a estado TERMINADO todos los eventos con fecha (fin) inferior a hoy Y que siguen en estado PENDIENTE
        total = Evento.where('fecha <=?', Date.today).where(estado: Evento::ESTATUS_PENDIENTE )
                .update_all(estado: Evento::ESTATUS_TERMINADO)
        puts "#{total} eventos actualizados a estatus TERMINADO"
        puts "#{Time.zone.now} TERMINA actualizar_estatus"
    end
     
    #TERMINAR UN SERVICIO PARA EVALUAR OTRA RAZON DADO CASO NO CONTRATO NINGUN PROFESIONISTA
    
    #0 Contrate a un profesional gracias a Yo Necesito
    #1 Contrate a un profesional fuera de Yo Necesito
    #2 Decidí hacerlo yo mismo
    #3 Hubo un cambio de planes
    #4 Otra razón
    
    EVALUACION_CONTRATE_PROFESIONAL_EN_YN = 0
    EVALUACION_CONTRATE_PROFESIONAL_FUERA = 1
    EVALUACION_LO_HICE_YO = 2
    EVALUACION_CAMBIO_PLANES = 3
    EVALUACION_OTRO = 4
    
    EVALUACION = [{id: EVALUACION_CONTRATE_PROFESIONAL_EN_YN, valor: 'Contrate a un profesional gracias a Yo Necesito.'},
                    {id: EVALUACION_CONTRATE_PROFESIONAL_FUERA, valor: 'Contrate a un profesional fuera de Yo Necesito.'},
                    {id: EVALUACION_LO_HICE_YO, valor: 'Decidí hacerlo yo mismo.'},
                    {id: EVALUACION_CAMBIO_PLANES, valor: 'Hubo un cambio de planes.'},
                    {id: EVALUACION_OTRO, valor: 'Otra razón.'}]
    
    # Devuelve el valor texto del id de EVALUACION indicado
    # Uso: Evento::get_evaluacion_estado(Evento::EVALUACION_LO_HICE_YO)
    def self.get_evaluacion_estado(id)
        hash = EVALUACION.detect {|u| u[:id] == id } 
        return hash[:valor]
    end
    #Devuelve el id del valor para params
    def self.get_id_evaluacion(valor)
        hash = EVALUACION.detect {|u| u[:valor] == valor } 
        return hash[:id]
    end
    
    
     
    
    
    
    
end
