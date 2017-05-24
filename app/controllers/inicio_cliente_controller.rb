class InicioClienteController < ApplicationController
  protect_from_forgery
  before_action :validar_login_cliente #heredado en application_controller.rb
  
  def index    
    ##condicion si el cliente tiene un servicio mandar a sus servicios dado caso no en panel 10
    #render :action => "servicios"

    @servicios_cliente = Evento.where(id_cliente: current_cliente.id).order(fecha_alta: :desc)
  
    if @servicios_cliente.nil?
      logger.info "no hay servicios pertenecientes al cliente"
    else  
    end
      
  end
  
  # Compartida para uso de selects de Estado-Ciudad en varias vistas
  # tag define el contenedor en params que provee valor de ciudad
  
  def set_variables_ciudad_estado(tag)
    @idCiudadActual = 0 #Ciudad default
    @idCiudadActual = current_cliente.id_ciudad_republica unless current_cliente.id_ciudad_republica.nil?
    @idCiudadActual = params[tag][:ciudad_id] unless params[tag].blank?
    @idEstadoActual = EstadosRepublica.first.id #Estado default
    @idEstadoActual = CiudadesRepublica.where(id: @idCiudadActual).first.id_estado unless @idCiudadActual == 0
    #Lectura de datos
    @estados = EstadosRepublica.all.order(:descripcion)
    @ciudades = CiudadesRepublica.where(id_estado: @idEstadoActual).order(:descripcion)
  end

  
  # Llamado en Ajax. Devuelve con JSON ciudades del Estado en parámetro params[:estado_id] 
  def get_ciudades
    @ciudades = CiudadesRepublica.where("id_estado = ?", params[:estado_id]).order(:descripcion)#.select('id, descripcion')
    respond_to do |format| format.json {render json: @ciudades} end
  end
  

  
  #PANEL datos básicos
  def datos_basicos
    @dia = 1
    @mes = "01"
    @ano = 2000
    if current_cliente.fecha_nacimiento
      @dia = current_cliente.fecha_nacimiento.day
      @ano = current_cliente.fecha_nacimiento.year
      @mes = current_cliente.fecha_nacimiento.month
      if @mes < 10 then @mes = "0"+@mes.to_s  end
    end
  end
  
  # Llamado desde vista datos_basicos
  def guardar_datos_basicos
    fecha_nacimiento = params[:ano]+"-"+params[:mes]+"-"+params[:dia]
    current_cliente.fecha_nacimiento = fecha_nacimiento
    current_cliente.nombre = params[:cliente][:nombre]
    current_cliente.apellido = params[:cliente][:apellido]
    current_cliente.sobre_ti = params[:cliente][:sobre_ti]
    current_cliente.sexo = params[:cliente][:sexo]
    current_cliente.save
    flash[:notice] = "Cambios guardados"
    redirect_to inicio_cliente_datos_basicos_path
  end
  
  #PANEL contacto
  def contacto
    set_variables_ciudad_estado(:profesionista) #Valores escogidos del usuario están en params[:profesionista]
  end
  
  def guardar_contacto
    # Forma cómoda pero insegura. permit! hace que funcione con model.update pero permitiría cualquier cosa. params.require().permit() no ayudó
    #params.permit!
    #parametros = params[:cliente].except(:estado_id).except(:ciudad_id).except(:email)
    #parametros[:id_ciudad_republica] = params[:cliente][:ciudad_id]
    #current_cliente.update(parametros)
    current_cliente.tel_fijo = params[:cliente][:tel_fijo]
    current_cliente.tel_celular = params[:cliente][:tel_celular]
    current_cliente.direccion = params[:cliente][:direccion]
    current_cliente.id_ciudad_republica = params[:cliente][:ciudad_id]
    current_cliente.cp = params[:cliente][:cp]
    current_cliente.save
    flash[:notice] = "Cambios guardados"
    redirect_to inicio_cliente_contacto_path
  end

  #PANEL verificaciones
  # El correo enviado en esta acción es validado en controlador inicio.validar_email_cliente
  # No se creó otra función para envío pues en esta misma funciona para algo simple con GET
  def verificaciones
    @enviado = "" #Indica que no hay envío
    if !params[:enviar_email].nil?
      begin
        UsuarioMailer.verificacion_correo_cliente(current_cliente).deliver
        flash[:notice] = "Correo enviado con éxito"
      rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
        flash[:notice] = "Ocurrió un error al enviar el correo: "+e.to_s #Indica error tal cual
      end
      redirect_to inicio_cliente_verificaciones_path
    end
  end
  
  #PANEL seguridad
  def seguridad
  end

  # PUT Actualización del password
  def cambiar_password
    parametros_password = params.require(:cliente).permit(:password, :password_confirmation, :current_password)
    if current_cliente.update_with_password(parametros_password)
      # Sign in the user by passing validation in case their password changed
      sign_in :cliente, current_cliente, :bypass => true
      flash[:notice] = "*Password cambiado exitosamente*"
      redirect_to inicio_cliente_seguridad_path
    else
      flash[:notice] = "*No fue posible cambiar el password*"
      render "seguridad" #En vez de redirect para conservar valores de error en current_cliente
      #Aunque podría guardarse contenido de errores en un notice si fuera necesario un redirect
    end
  end


  # PANEL foto
  def foto
    if !params[:cliente].nil? && !params[:cliente][:archivo].nil?
      archivo = params[:cliente][:archivo]
      @resultado = "archivo recibido " + archivo.tempfile.to_s
      if archivo.content_type != "image/jpeg" && archivo.content_type != "image/png" && archivo.content_type != "image/gif"
        @resultado = "Tipo de imágen inválido"
        return
      end
      if archivo.size > 500.kilobytes
        @resultado = "Foto demasiado pesada. Tamaño máximo de 500 KB"
        return
      end
      File.open(Rails.root.join('public', 'fotos_clientes', current_cliente.id.to_s), 'wb') do |file|
        file.write(archivo.read)
      end
      Thread.new { GC.start } # Ayuda a borrar archivos temporales "RackMultipartYYYYMMDD-XXXX"
      @resultado = "Foto modificada con éxito"
    else
      @resultado = ""
    end
  end


  def categorias
    #mostrar las categorias existentes
    @hogar = TiposTrabajo.where(categoria: :hogar)
    #
    @eventos = TiposTrabajo.where(categoria: :eventos)
    
    @bienestar = TiposTrabajo.where(categoria: :bienestar)
    
    @educacion = TiposTrabajo.where(categoria: :clases)

  end
  
  # En URL recibe parámetros :servicio (string) y :id_servicio (id_tipo_trabajo)
  def solicitar_servicios
      #nombre del servicio
      if !params[:id_servicio].present?
        redirect_to inicio_cliente_categorias_path
        return
      end
      @id_servicio = params[:id_servicio]
      @servicio = TiposTrabajo.find(@id_servicio).servicio #Título del servicio (tipo_trabajo)
      
      ##Creación de datos básicos
      set_variables_ciudad_estado(:cliente)
      @miSolicitud = Evento.new
      @miSolicitud.id_cliente = current_cliente.id
      @miSolicitud.id_tipo_trabajo = @id_servicio
      
      #Lectura de preguntas dinámicas
      @plantilla_json = TiposTrabajo.find(@miSolicitud.id_tipo_trabajo).plantilla_json
      @plantilla_json = "[]" if !@plantilla_json.present?
      @plantilla = JSON.parse @plantilla_json
  end
  
  # Llamado desde solicitar_servicios para guardar un nuevo Evento
  def guardar_servicios
    #parametros = params.require(:evento).permit(:descripcion)
    @miSolicitud = Evento.new
    @miSolicitud.id_cliente = current_cliente.id
    @miSolicitud.id_tipo_trabajo = params[:evento][:id_tipo_trabajo]
    
    @miSolicitud.descripcion = params[:evento][:descripcion]
    @miSolicitud.urgencia_necesidad = params[:evento][:urgencia_necesidad]
    @miSolicitud.fecha =  params[:evento][:fecha]
    @miSolicitud.hora =  params[:evento][:hora]
    @miSolicitud.tiempo =  params[:evento][:tiempo]
    @miSolicitud.direccion_completa =  params[:evento][:direccion_completa]
    @miSolicitud.colonia =  params[:evento][:colonia]
    @miSolicitud.cp =  params[:evento][:cp]
    @miSolicitud.correo_electronico =  params[:evento][:correo_electronico]
    @miSolicitud.telefono_movil =  params[:evento][:telefono_movil]
    @miSolicitud.telefono_fijo =  params[:evento][:telefono_fijo]
    @miSolicitud.presupuesto_por_llamada =  params[:evento][:presupuesto_por_llamada]
    
    @miSolicitud.id_ciudad_republica = params[:cliente][:id_ciudad_republica]
    @miSolicitud.id_estado_republica = params[:cliente][:id_estado_republica]
    
    @miSolicitud.estado = Evento::ESTATUS_PENDIENTE #1 Pendiente (al insertar registro)\n2 Terminado (al cumplirse la fecha del evento)\n3 Evaluado (al evaluar el evento)
    #@miSolicitud.evaluacion_estado = 0   #0 Contrate a un profesional gracias a Yo Necesito\n1 Contrate a un profesional fuera de Yo Necesito\n2 Decidí hacerlo yo mismo\n3  Hubo un cambio de planes\n4 Otra razón
    #@miSolicitud.otra_razon = ""
    @miSolicitud.fecha_alta = Date.today
    
    
    #Lectura de preguntas dinámicas
    @plantilla_json = TiposTrabajo.find(@miSolicitud.id_tipo_trabajo).plantilla_json
    @plantilla_json = "[]" if !@plantilla_json.present?
    @plantilla = JSON.parse @plantilla_json
    
    plantilla_completa = Array.new # contenedor de salida
    @plantilla.each_with_index do |pregunta, i|
       respuesta_post = params["respuestas"][i.to_s]
       respuesta_post["opciones"] = Array.new if respuesta_post["opciones"].nil?
       respuesta = Array.new(respuesta_post["opciones"]) #copiamos respuestas
       respuesta.delete("Otro") #quitamos opción "Otro" en la copia (si la hay) y le agregamos el texto del usuario
       respuesta.push respuesta_post["otro"] if respuesta_post["opciones"].include?("Otro") && !respuesta_post["otro"].nil?
       hash = { titulo: pregunta["titulo"], respuestas: respuesta}
       plantilla_completa.push hash
    end
    @miSolicitud.plantilla_json_completa = plantilla_completa.to_json #respuestas convertidas a JSON
    
    # guardar post
    if @miSolicitud.save
      # indicar que funcióno bien
      #redirigir resdirect_to ....
      logger.info "Redirigiremos a " + inicio_cliente_index_path
      redirect_to inicio_cliente_index_path
    else
      #No salió
      flash[:notice] = "No fue posible guardar el servicio"
      render "solicitar_servicios"
    end
  end
  
  #mostrar el servicio del cliente conforme al id servicio
  def ver_servicio
    #obtener el id y titulo del servicio para ver servicio de lo solicitado del cliente
     @id_servicio = params[:id_evento]
     
     @servicio_cliente = Evento.find_by(id: @id_servicio) or mostrar_404
     @servicio = TiposTrabajo.find(@servicio_cliente.id_tipo_trabajo).servicio #Título del servicio (tipo_trabajo)
     @plantilla_respuesta = JSON.parse @servicio_cliente.plantilla_json_completa
  end
  
  
  # Mostrara botones con los profesionistas contratables para el servicio actual Y detalllará mensajes de uno solo de ellos
  # params[:id_evento] Indica el evento/servicio que se está visualizando
  # params[:id_profesionista_evento] indica el registro en ProfesionistasXEventos que se ve actualmente (puede no estar definido)
  def mensaje_servicio
    #validamos que id_evento pertenece a current_cliente
    @evento = Evento.find_by(id: params[:id_evento], id_cliente: current_cliente.id) or mostrar_404
    #@evento = Evento.find(params[:id_evento])
    
    @servicio = TiposTrabajo.find(@evento.id_tipo_trabajo).servicio #Título del servicio (tipo_trabajo)   
    @profesionistas_contratables = ProfesionistasXEventos.where(id_evento: @evento.id, 
        estado: ProfesionistasXEventos::ESTADO_PENDIENTE)
        
    
    @profesionistas_contratables_contratados = ProfesionistasXEventos.where(id_evento: @evento.id, 
        estado: [ProfesionistasXEventos::ESTADO_PENDIENTE, ProfesionistasXEventos::ESTADO_CONTRATADO_SIN_EVALUAR,ProfesionistasXEventos::ESTADO_CONTRATADO_EVALUADO])
            

    # Obtenemos "tab" visualizado actualmente. Será nil al entrar por primera vez a la página
    @contratable_seleccionado = ProfesionistasXEventos.find_by(id: params[:id_profesionista_evento]) #unless params[:id_profesionista_evento].nil?
    
    # Validamos que no hackeen introduciendo un contratable falso
    if !@contratable_seleccionado.nil? && @contratable_seleccionado.id_evento != @evento.id
      mostrar_404 "El contratable seleccionado no pertenece al evento actual"
      return
    end
    
    # Aquí, contratable es un registro válido ó NIL (al no haber uno seleccionado) 
    
    if !@contratable_seleccionado.nil? #Si estamos visualizando una cotización
      
      #sacamos  la informacion de profecionista
      @profesionista_seleccionado = Profesionista.find(@contratable_seleccionado.id_profesionista)
      @mensajes = Mensajes::get_todos_mensajes_para_cliente(current_cliente.id, @contratable_seleccionado.id)
      #obtenemos la cuidad y estado
      
      @ciudad = "" 
      @estado = ""
      
      if !@profesionista_seleccionado.id_ciudad_republica.nil?
        ciudad = CiudadesRepublica.find(@profesionista_seleccionado.id_ciudad_republica)
        @ciudad = ciudad.descripcion
        @estado = EstadosRepublica.find(ciudad.id_estado).descripcion  
      end
      
    end
    
    
  end
  
  #enviamos el mensaje directo al profecionista en base a 
  # params[:id_evento] Indica el evento/servicio que se está visualizando
  # params[:id_profesionista_evento] indica el registro en ProfesionistasXEventos que se ve actualmente (puede no estar definido)
  #que esta hereda de mensaje_servicio()
  def enviar_mensaje_servicio
    mensaje_servicio()
    #se guarda el mensaje que respondio el cliente al profesionista
    mensaje = Mensajes.new
    mensaje.id_profesionista_evento = @contratable_seleccionado.id
    mensaje.id_profesionista = @profesionista_seleccionado.id
    mensaje.titulo=""
    mensaje.id_cliente = current_cliente.id
    mensaje.fecha_hora = Time.now
    mensaje.fuente = Mensajes::FUENTE_CLIENTE
    mensaje.contenido = params[:contenido]
    if mensaje.save
      flash[:notice] = "Mensaje enviado exitosamente"
      render 'mensaje_servicio'
    else
      flash[:notice] = "Mensaje no enviado"
      render 'mensaje_servicio'
    end
  end
  
  #guardamos el contrato de profesionista cuando es contratado
  # params[:id_evento] Indica el evento/servicio que se está visualizando
  # params[:id_profesionista_evento] indica el registro en ProfesionistasXEventos que se ve actualmente (puede no estar definido)  
  #heredamos los params para el metodo mensaje_servicio
  def guardar_contrato_servicio
    mensaje_servicio()
    #se cambia el estado del profecionista x evento que fue contratado
    @contratable_seleccionado.estado = ProfesionistasXEventos::ESTADO_CONTRATADO_SIN_EVALUAR
    @contratable_seleccionado.save
    #render 'mensaje_servicio'
    redirect_to inicio_cliente_mensaje_servicio_path(id_evento: @evento.id)
  end
  
  #guardamos el motivo rechazo de profesionista cuando es rechazado
  # params[:id_evento] Indica el evento/servicio que se está visualizando
  # params[:id_profesionista_evento] indica el registro en ProfesionistasXEventos que se ve actualmente (puede no estar definido)  
  #heredamos los params para el metodo mensaje_servicio
  def guardar_rechazo_servicio
    mensaje_servicio()
    
    #comparar si es un rechazo o otro motivo para guardar 
    @motivo_rechazo = ProfesionistasXEventos::get_id_rechazado(params[:motivo_rechazo])
    if @motivo_rechazo == ProfesionistasXEventos::OTRO_MOTIVO
      #se cambia el estado del profecionista x evento que fue contratado
      @contratable_seleccionado.estado = ProfesionistasXEventos::ESTADO_RECHAZADO_SIN_EVALUAR
      @contratable_seleccionado.motivo_rechazo = ProfesionistasXEventos::get_id_rechazado(params[:motivo_rechazo])
      @contratable_seleccionado.otro_motivo = params[:otro_motivo]
      logger.info "es otro motivo"
    else
      @contratable_seleccionado.motivo_rechazo = params[:motivo_rechazo]
      @contratable_seleccionado.estado = ProfesionistasXEventos::ESTADO_RECHAZADO_SIN_EVALUAR
      @contratable_seleccionado.motivo_rechazo = ProfesionistasXEventos::get_id_rechazado(params[:motivo_rechazo])
      logger.info "es motivo rechazo"
    end
    @contratable_seleccionado.save
    #render 'mensaje_servicio'
    redirect_to inicio_cliente_mensaje_servicio_path(id_evento: @evento.id)
  end
  
  # VISTA donde se ve uno de los dos pasos en proceso de calificación del cliente.
  # En paso 1 se mandará post a acción guardar_terminar_servicio
  # En paso 2 se mandará post a acción guardar_evaluar_servicio
  # params[:id_evento] Entero con id de modelo Evento
  def terminar_servicio
    #validamos que id_evento pertenece a current_cliente
    
    @evento = Evento.find_by(id: params[:id_evento], id_cliente: current_cliente.id) or mostrar_404
    #@evento = Evento.find(params[:id_evento])
   
    @profesionistas_contratados = ProfesionistasXEventos.where(id_evento: @evento.id, 
        estado: ProfesionistasXEventos::ESTADO_CONTRATADO_SIN_EVALUAR)
        
    @profesionistas_contratables = ProfesionistasXEventos.where(id_evento: @evento.id, 
        estado: ProfesionistasXEventos::ESTADO_PENDIENTE)
  end
  
  
  # Procesa el 1er paso de la vista terminar_servicio
  # Según el contexto del servicio y contratables o contratados registrará la evaluación del evento
  # params[:id_evento] Entero con id de modelo Evento
  # params["calificable"] Arreglo de strings con IDs de ProvesionistaXEvento
  # params[:evaluacion_estado] Entero con valor destinado a columna evaluacion_estado de un Evento
  def guardar_terminar_servicio
    terminar_servicio() # para alimentar variables @ de terminar_servicio
    hubo_contrataciones = false # Indica si hubo contrataciones para el evento
    if @profesionistas_contratados.length > 0
      hubo_contrataciones = true
    end

    # Valida si se escogieron profesionistas_contratables para actualizar su estatus de contratación
    contratables_escogidos = params["calificable"] || Array.new
    @profesionistas_contratables.each do |contratable|
      if contratables_escogidos.include?(contratable.id_profesionista.to_s)
        contratable.estado = ProfesionistasXEventos::ESTADO_CONTRATADO_SIN_EVALUAR
        contratable.save
        hubo_contrataciones = true
      end
    end
    
    @evento.estado = Evento::ESTATUS_TERMINADO
    
    if !hubo_contrataciones
      # Determinamos valor de rechazo con preguntas de rechazo
      valor_evaluacion = params[:evaluacion_estado]
      if valor_evaluacion.nil? || valor_evaluacion.blank?
        flash.now[:notice] = "Es necesario especificar motivo por el que no contrataste con Yo Necesito"
        render "terminar_servicio"
        return
      end
      @evento.evaluacion_estado = valor_evaluacion
      if valor_evaluacion == Evento::EVALUACION_OTRO
        @evento.otra_razon = params[:otra_razon]
        logger.info "es otra razon"
      else
        logger.info "es diferente razón"
      end
    else
      @evento.evaluacion_estado = Evento::EVALUACION_CONTRATE_PROFESIONAL_EN_YN
      logger.info "contrató en yo ns"
    end
    
    # Se rechazan todos los que no fueron contratados de alguna forma
    ProfesionistasXEventos.where(id_evento: @evento.id, estado: ProfesionistasXEventos::ESTADO_PENDIENTE).update_all(estado: ProfesionistasXEventos::ESTADO_RECHAZADO_SIN_EVALUAR)
    
    if @evento.save
      flash[:notice] = "Ha terminado la primera fase de terminación de servicio"
    else
      flash[:notice] = "No fue posible guardar su elección"
    end
    redirect_to inicio_cliente_terminar_servicio_path(id_evento: @evento.id) #inicio_cliente_index_path
  end
  
  
  # Procesa el 2do paso de la vista terminar_servicio
  # Según el contexto del servicio y contratables o contratados registrará la evaluación del evento
  # params[:id_evento] Entero con id de modelo Evento
  # params["evaluacion[ProfesionistaXEvento.id_profesionista]"] Arreglo bidimensional con los siguientes valores por cada localidad de id_profesionista:
  #     [calificacion] Entero con valor del 1 al 5 indicando la calificación de id_profesionista
  #     [comentarios]  String con valoración cualitativa del cliente hacia id_profesionista
  def guardar_evaluar_servicio
    terminar_servicio() # para alimentar variables de instancia @ de terminar_servicio
    
    evaluados = params['evaluacion'] or Array.new # Obtenemos los resultados de evaluación O nada

    evaluados.map do |id_profesionista, valores| # recorremos el hash de 2 valores para cada profesionista
      contratado = @profesionistas_contratados.find_by(id_profesionista: id_profesionista)
      if contratado then #Si existe el contratado
        #flash[:notice] = (flash[:notice] or "") + " id encontrado: " + id_profesionista + " con calif:" + valores["calificacion"] + " y comentarios "+valores["comentarios"]
        contratado.estado = ProfesionistasXEventos::ESTADO_CONTRATADO_EVALUADO
        contratado.fecha_calificacion = Time.now
        contratado.calificacion_cliente = valores["calificacion"]
        contratado.comentarios_cliente = valores["comentarios"]
        if contratado.save
          profesionista = Profesionista.find(id_profesionista)
          profesionista.numero_estrellas += contratado.calificacion_cliente
          profesionista.numero_calificaciones += 1
          profesionista.save
        else
          logger.info "Se intentó guardar sin éxito una calificación para profesionista #{id_profesionista} con calificacion #{contratado.calificacion_cliente} y comentarios #{contratado.comentarios_cliente}"
        end
      else
        logger.info "Se intentó calificar equivocadamente al profesionista #{id_profesionista} en evento #{@evento.id}"
      end
    end #fin ciclo

    @evento.estado = Evento::ESTATUS_EVALUADO
    @evento.save
    redirect_to inicio_cliente_terminar_servicio_path(id_evento: @evento.id)
  end
  
  
  
end