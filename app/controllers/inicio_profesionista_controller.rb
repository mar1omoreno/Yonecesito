class InicioProfesionistaController < ApplicationController
  protect_from_forgery
  before_action :validar_login_profesionista #heredado en application_controller.rb
  
  # Home de profesionista con trabajos/servicios asignados a él
  def index
    @profesionista_eventos = ProfesionistasXEventos.where(id_profesionista: current_profesionista.id).order(:fecha_aplicacion => :desc)
    render :action => "trabajos"
  end

  # Compartida para uso de selects de Estado-Ciudad en varias vistas
  # tag define el contenedor en params que provee valor de ciudad
  def set_variables_ciudad_estado(tag)
    @idCiudadActual = 0 #Ciudad default
    @idCiudadActual = current_profesionista.id_ciudad_republica unless current_profesionista.id_ciudad_republica.nil?
    @idCiudadActual = params[tag][:ciudad_id] unless params[tag].blank?
    @idEstadoActual = EstadosRepublica.first.id #Estado default
    @idEstadoActual = CiudadesRepublica.where(id: @idCiudadActual).first.id_estado unless @idCiudadActual == 0
    #Lectura de datos
    @estados = EstadosRepublica.all.order(:descripcion)
    @ciudades = CiudadesRepublica.where(id_estado: @idEstadoActual).order(:descripcion)
  end

  # Vista de búsqueda de trabajo en ciudad
  def buscar_trabajo
    set_variables_ciudad_estado(:filtro) #Valores escogidos del usuario están en params[:filtro]
    @tiposTrabajo = ProfesionistasXTrabajos.where(id_profesionista: current_profesionista.id).select(:id_tipo_trabajo)
    @eventos = Evento.where(id_ciudad_republica: @idCiudadActual, id_tipo_trabajo: @tiposTrabajo, 
        estado: Evento::ESTATUS_PENDIENTE ).where("fecha >?",Time.now).order(:fecha)
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
    if current_profesionista.fecha_nacimiento
      @dia = current_profesionista.fecha_nacimiento.day
      @ano = current_profesionista.fecha_nacimiento.year
      @mes = current_profesionista.fecha_nacimiento.month
      if @mes < 10 then @mes = "0"+@mes.to_s  end
    end
  end
  
  def guardar_datos_basicos
    fecha_nacimiento = params[:ano]+"-"+params[:mes]+"-"+params[:dia]
    current_profesionista.fecha_nacimiento = fecha_nacimiento
    current_profesionista.nombre = params[:profesionista][:nombre]
    current_profesionista.apellido = params[:profesionista][:apellido]
    current_profesionista.empresa = params[:profesionista][:empresa]
    current_profesionista.sobre_empresa = params[:profesionista][:sobre_empresa]
    current_profesionista.sexo = params[:profesionista][:sexo]
    current_profesionista.save
    flash[:notice] = "Cambios guardados"
    redirect_to inicio_profesionista_datos_basicos_path
  end
  
  #PANEL contacto
  def contacto
    set_variables_ciudad_estado(:profesionista) #Valores escogidos del usuario están en params[:profesionista]
  end
  
  def guardar_contacto
    # Forma cómoda pero insegura. permit! hace que funcione con model.update pero permitiría cualquier cosa. params.require().permit() no ayudó
    #params.permit!
    #parametros = params[:profesionista].except(:estado_id).except(:ciudad_id).except(:email)
    #parametros[:id_ciudad_republica] = params[:profesionista][:ciudad_id]
    #current_profesionista.update(parametros)
    current_profesionista.pagina_web = params[:profesionista][:pagina_web]
    current_profesionista.tel_fijo = params[:profesionista][:tel_fijo]
    current_profesionista.tel_celular = params[:profesionista][:tel_celular]
    current_profesionista.direccion = params[:profesionista][:direccion]
    current_profesionista.id_ciudad_republica = params[:profesionista][:ciudad_id]
    current_profesionista.cp = params[:profesionista][:cp]
    current_profesionista.save
    flash[:notice] = "Cambios guardados"
    redirect_to inicio_profesionista_contacto_path
  end

  # PANEL foto
  def foto
    if !params[:profesionista].nil? && !params[:profesionista][:archivo].nil?
      archivo = params[:profesionista][:archivo]
      @resultado = "archivo recibido " + archivo.tempfile.to_s
      if archivo.content_type != "image/jpeg" && archivo.content_type != "image/png" && archivo.content_type != "image/gif"
        @resultado = "Tipo de imágen inválido"
        return
      end
      if archivo.size > 500.kilobytes
        @resultado = "Foto demasiado pesada. Tamaño máximo de 500 KB"
        return
      end
      File.open(Rails.root.join('public', 'fotos_profesionistas', current_profesionista.id.to_s), 'wb') do |file|
        file.write(archivo.read)
      end
      Thread.new { GC.start } # Ayuda a borrar archivos temporales "RackMultipartYYYYMMDD-XXXX"
      @resultado = "Foto modificada con éxito"
    else
      @resultado = ""
    end
  end

  #PANEL verificaciones
  # El correo enviado en esta acción es validado en controlador inicio.validar_email_profesionista
  # No se creó otra función para envío pues en esta misma funciona para algo simple con GET
  def verificaciones
    @enviado = "" #Indica que no hay envío
    if !params[:enviar_email].nil?
      begin
        UsuarioMailer.verificacion_correo_profesionista(current_profesionista).deliver
        flash[:notice] = "Correo enviado con éxito"
      rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
        flash[:notice] = "Ocurrió un error al enviar el correo: "+e.to_s #Indica error tal cual
      end
      redirect_to inicio_profesionista_verificaciones_path
    end
  end
  
  #PANEL seguridad
  def seguridad
  end

  # PUT Actualización del password
  def cambiar_password
    parametros_password = params.require(:profesionista).permit(:password, :password_confirmation, :current_password)
    if current_profesionista.update_with_password(parametros_password)
      # Sign in the user by passing validation in case their password changed
      sign_in :profesionista, current_profesionista, :bypass => true
      flash[:notice] = "*Password cambiado exitosamente*"
      redirect_to inicio_profesionista_seguridad_path
    else
      flash[:notice] = "*No fue posible cambiar el password*"
      render "seguridad" #En vez de redirect para conservar valores de error en current_profesionista
      #Aunque podría guardarse contenido de errores en un notice si fuera necesario un redirect
    end
  end


  #PANEL mis servicios
  def panel_servicios
    #Consultamos categorías (select distinct)
    @categorias = TiposTrabajo.uniq.pluck(:categoria)

    # Los tipos de servicio que tiene elegidos el usuario
    @tiposTrabajoSeleccionados = ProfesionistasXTrabajos.where(id_profesionista: current_profesionista.id)
  end
  
  # Llamado en Ajax. Devuelve con JSON tipos de trabajo de categoría en parámetro params[:categoria] 
  def get_tipos_trabajo_de_categoria
    tipos = TiposTrabajo.where(categoria: params[:categoria]).order(:servicio).select('id, servicio')
    respond_to do |format| format.json {render json: tipos} end
  end

  # Guarda los tipos de trabajo que estén seleccionados en vista panel_servicios
  def guardar_servicios
    if params[:servicio]
      @idTiposTrabajoEscogidos = params[:servicio].uniq #tipos de trabajo sin repeticiones
      @idTiposTrabajoEscogidos.delete("") #Quitamos elecciones vacías
      if @idTiposTrabajoEscogidos.length == 0 then
        flash[:notice] = "*Debe escoger al menos un servicio*"
        redirect_to inicio_profesionista_panel_servicios_path
        return
      end
      # Se borran viejos tipos de trabajo
      ProfesionistasXTrabajos.delete_all(id_profesionista: current_profesionista.id)
      # Se agregan nuevos tipos de trabajo
      @idTiposTrabajoEscogidos.each do |idTipo|
        reg = ProfesionistasXTrabajos.create(id_tipo_trabajo: idTipo, id_profesionista: current_profesionista.id)
        reg.save
      end
    end
    flash[:notice] = "*Cambios guardados*"
    redirect_to inicio_profesionista_panel_servicios_path
  end

  
  
  
end
