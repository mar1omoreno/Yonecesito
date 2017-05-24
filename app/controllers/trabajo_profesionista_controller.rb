class TrabajoProfesionistaController < ApplicationController
    protect_from_forgery
    before_action :validar_login_profesionista #heredado en application_controller.rb
  
    # VISTA detalles de un evento con capacidad de aplicar cotización
    # params[:id_evento] indica el trabajo que se visualiza y que se puede aplicar
    def ver
        @evento = Evento.find_by_id(params[:id_evento]) or mostrar_404

        @cliente = Cliente.find(@evento.id_cliente)
        
        @plantilla_respuestas = JSON.parse @evento.plantilla_json_completa
        
        @nombre_trabajo = TiposTrabajo.find(@evento.id_tipo_trabajo).servicio
        ciudad = CiudadesRepublica.find(@evento.id_ciudad_republica)
        @nombre_ciudad = ciudad.descripcion
        @nombre_estado = EstadosRepublica.find(ciudad.id_estado).descripcion
        
        # Esta variable será nil si el profesionista aún no aplica/cotiza al evento
        @profesionista_evento = ProfesionistasXEventos.where(id_evento: @evento.id, id_profesionista: current_profesionista.id).first
        
        if !@profesionista_evento.nil? # Si ya existe cotización
            @mensajes = Mensajes::get_todos_mensajes_para_profesionista(current_profesionista.id, @profesionista_evento.id)
        end
    end
    
    # acción que cotiza el evento
    def cotizar
        ver() # Inicializamos variables que sirven también aquí
        if @evento.estado != Evento::ESTATUS_PENDIENTE # Si el evento NO es aplicable
            flash[:notice] = "Este evento está terminado"
            render 'ver'
            return
        end
        #Validamos que el evento es cotizable
        if !@profesionista_evento.nil? # Si ya existe el registro
            flash[:notice] = "Este evento ya fue cotizado anteriormente"
            render 'ver'
            return
        end
        if current_profesionista.creditos < Evento::COSTO_CREDITOS_APLICAR
            flash[:notice] = "No se tienen suficientes créditos para enviar cotización"
            render 'ver'
            return
        end
        
        monto = params[:cotizacion_monto] # TODO ¿CONVERTIR A money?
        # Creamos cotización
        cotizacion = ProfesionistasXEventos.new
        cotizacion.id_evento = @evento.id
        cotizacion.id_profesionista = current_profesionista.id
        cotizacion.creditos_consumidos = Evento::COSTO_CREDITOS_APLICAR
        if cotizacion.save
            # Creamos nuevo mensaje con la cotización
            mensaje = Mensajes.new
            mensaje.id_profesionista_evento = cotizacion.id
            mensaje.id_profesionista = current_profesionista.id
            mensaje.id_cliente = @evento.id_cliente
            mensaje.fecha_hora = Time.now
            mensaje.cotizacion = monto
            mensaje.titulo = "" # en realidad no lo usamos
            mensaje.contenido = params[:cotizacion_detalles]
            if mensaje.save
                current_profesionista.creditos = current_profesionista.creditos - cotizacion.creditos_consumidos
                if current_profesionista.save
                    begin
                        UsuarioMailer.nuevo_mensaje( mensaje.id_cliente ).deliver #Intentamos enviar correo
                    rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
                    end
                    flash[:notice] = "Cotización enviada exitosamente"
                    redirect_to trabajo_profesionista_ver_path(id_evento: @evento.id) #redirigir a inicio_profesionista_index_path ? 
                else
                    flash[:notice] = "No se pudo restar los créditos para la cotización"
                    render 'ver'
                end
            else
                flash[:notice] = "No se pudo guardar el mensaje con la cotización"
                render 'ver'
            end
        else
            flash[:notice] = "No se pudo guardar la cotización"
            render 'ver'
        end
    end
    
    # Envía un mensaje al cliente en POST
    # params[:contenido]
    def enviar_mensaje
        ver() #activa variables compartidas @
         #se guarda el mensaje que respondio el cliente al profesionista
        mensaje = Mensajes.new
        mensaje.id_profesionista_evento = @profesionista_evento.id
        mensaje.id_profesionista = current_profesionista.id
        mensaje.titulo=""
        mensaje.id_cliente = @cliente.id
        mensaje.fecha_hora = Time.now
        mensaje.fuente = Mensajes::FUENTE_PROFESIONISTA
        mensaje.contenido = params[:contenido]
        if mensaje.save
            flash[:notice] = "Mensaje enviado exitosamente"
            render 'ver'
        else
            flash[:notice] = "Mensaje no enviado"
            render 'ver'
        end
    end
    
end