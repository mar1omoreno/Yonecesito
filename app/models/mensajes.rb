class Mensajes < ActiveRecord::Base

    FUENTE_PROFESIONISTA = 0
    FUENTE_CLIENTE = 1
    
    MENSAJE_LEIDO = 1
    MENSAJE_NO_LEIDO = 0

    #### FUNCIONES HELPER PARA MENSAJES
    
    # Indica si hay mensajes nuevos para cliente con id
    def self.hay_mensajes_nuevos_para_cliente(id)
        return Mensajes.where(id_cliente: id, estado: MENSAJE_NO_LEIDO, fuente: FUENTE_PROFESIONISTA).length > 0
    end
    
    # Regresa mensajes nuevos para el cliente de una cotización (id_profesionista_evento) específica
    def self.get_mensajes_nuevos_para_cliente(id_cliente, id_profesionista_evento )
        return Mensajes.where(id_cliente: id_cliente, id_profesionista_evento: id_profesionista_evento, fuente: FUENTE_PROFESIONISTA, estado: MENSAJE_NO_LEIDO).order(:fecha_hora)
    end
    
    # Regresa mensajes para el cliente de una cotización (id_profesionista_evento) específica
    def self.get_mensajes_para_cliente(id_cliente, id_profesionista_evento )
        return Mensajes.where(id_cliente: id_cliente, id_profesionista_evento: id_profesionista_evento, fuente: FUENTE_PROFESIONISTA).order(:fecha_hora)
    end
    
    # Regresa mensajes para el cliente de una cotización (id_profesionista_evento) específica
    def self.get_todos_mensajes_para_cliente(id_cliente, id_profesionista_evento )
        return Mensajes.where(id_cliente: id_cliente, id_profesionista_evento: id_profesionista_evento).order(:fecha_hora)
    end
    
    # Cambia el estado a leído de los mensajes en una cotización (id_profesionista_evento)
    def self.marcar_mensajes_para_cliente_leidos(id_cliente, id_profesionista_evento)
        Mensajes.where(id_cliente: id_cliente, id_profesionista_evento: id_profesionista_evento, fuente: FUENTE_PROFESIONISTA).update_all(estado: MENSAJE_LEIDO)
    end
    
    # Regresa mensajes nuevos para el cliente de cualquier cotización en un evento específico
    def self.get_mensajes_nuevos_para_cliente_de_evento(id_cliente, id_evento)
        return Mensajes.joins("join profesionistas_x_eventos pe ON pe.id = mensajes.id_profesionista_evento ")
                .where(pe: {id_evento: id_evento}, id_cliente: id_cliente, fuente: FUENTE_PROFESIONISTA, estado: MENSAJE_NO_LEIDO ).order(:fecha_hora)
    end
    
    # Regresa mensajes para el cliente de cualquier cotización en un evento específico
    def self.get_mensajes_para_cliente_de_evento(id_cliente, id_evento)
        return Mensajes.joins("join profesionistas_x_eventos pe ON pe.id = mensajes.id_profesionista_evento ")
                .where(pe: {id_evento: id_evento}, id_cliente: id_cliente, fuente: FUENTE_PROFESIONISTA).order(:fecha_hora)
    end
    
    
    #### Equivalente para profesionistas
    
    # Indica si hay mensajes nuevos para profesionista con id
    def self.hay_mensajes_nuevos_para_profesionista(id)
        return Mensajes.where(id_profesionista: id, estado: MENSAJE_NO_LEIDO, fuente: FUENTE_CLIENTE).length > 0
    end
    
    # Regresa mensajes nuevos para el profesionista de una cotización (id_profesionista_evento) específica
    def self.get_mensajes_nuevos_para_profesionista(id_profesionista, id_profesionista_evento )
        return Mensajes.where(id_profesionista: id_profesionista, id_profesionista_evento: id_profesionista_evento, fuente: FUENTE_CLIENTE, estado: MENSAJE_NO_LEIDO).order(:fecha_hora)
    end
    
    # Regresa mensajes para el profesionista de una cotización (id_profesionista_evento) específica
    def self.get_mensajes_para_profesionista(id_profesionista, id_profesionista_evento )
        return Mensajes.where(id_profesionista: id_profesionista, id_profesionista_evento: id_profesionista_evento, fuente: FUENTE_CLIENTE).order(:fecha_hora)
    end

    # Regresa mensajes para el profesionista de una cotización (id_profesionista_evento) específica
    def self.get_todos_mensajes_para_profesionista(id_profesionista, id_profesionista_evento )
        return Mensajes.where(id_profesionista: id_profesionista, id_profesionista_evento: id_profesionista_evento).order(:fecha_hora)
    end
    
    # Cambia el estado a leído de los mensajes en una cotización (id_profesionista_evento)
    def self.marcar_mensajes_para_profesionista_leidos(id_profesionista, id_profesionista_evento)
        Mensajes.where(id_profesionista: id_profesionista, id_profesionista_evento: id_profesionista_evento, fuente: FUENTE_CLIENTE).update_all(estado: MENSAJE_LEIDO)
    end
    
    
    
    
    
end
