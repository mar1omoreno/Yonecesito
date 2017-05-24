# Ejemplo de un controlador para profesionista que visualiza y edita información
# Algunos consejos tomados de https://kernelgarden.wordpress.com/2014/02/26/dynamic-select-boxes-in-rails-4/
# Esta clase es un ejemplo de cómo cargar una página de profile/propiedades de alguna entidad en rails
# y guardar cambios de dicha información. Maneja caso de cascada de listas select
class DummyController < ApplicationController
    before_action :validar_login_profesionista #heredado en application_controller.rb
    

    # Lista formulario para llenar
    def index
        @idCiudadUsuario = 0 #Ciudad default
        @idCiudadUsuario = current_profesionista.id_ciudad_republica unless current_profesionista.id_ciudad_republica.nil?
        #@idCiudadUsuario = params[:geografico][:ciudad_id] unless params[:geografico].blank?
        @idEstadoActual = EstadosRepublica.first.id #Estado default
        @idEstadoActual = CiudadesRepublica.where("id = ?", @idCiudadUsuario).first.id_estado unless @idCiudadUsuario == 0
        #Lectura de datos
        @estados = EstadosRepublica.all.order(:descripcion)
        @ciudades = CiudadesRepublica.where("id_estado = ?", @idEstadoActual).order(:descripcion)
    end

    # Llamado en Ajax. Devuelve con JSON ciudades del Estado en parámetro params[:estado_id] 
    def get_ciudades
        @ciudades = CiudadesRepublica.where("id_estado = ?", params[:estado_id]).order(:descripcion)#.select('id, descripcion')
        respond_to do |format| format.json {render json: @ciudades} end
    end
    
    # Guarda profile con datos contenidos en params[:geografico]
    def guardar
        current_profesionista.id_ciudad_republica = params[:geografico][:ciudad_id] unless params[:geografico].blank?
        current_profesionista.save
        flash[:notice] = "Cambios guardados" #Asignar esto en redirect_to no lograba hacer visible el mensaje
        redirect_to action: 'index'
    end
   
   
   ID_PLANTILLA = 11
   def prueba_plantilla_json
       @miSolicitud = Evento.new
       @plantilla_json = TiposTrabajo.find(ID_PLANTILLA).plantilla_json
       @plantilla_json = "[]" if !@plantilla_json.present?
       @plantilla = JSON.parse @plantilla_json
   end
   
   # Genera un JSON con arreglo de respuestas a las preguntas respondidas.
   # La estructura de params es similar a la siguiente:  
   # "respuestas"=>{"0"=>{"tipo"=>"checkbox", "opciones"=>["Opción 2"], "otro"=>""}, "1"=>{"tipo"=>"radio", "opciones"=>["Opción 2"], "otro"=>""}, "2"=>{"tipo"=>"select", "opciones"=>["Opción 1"]}, "3"=>{"tipo"=>"texto", "opciones"=>["sad"]}}
   def guardar_prueba_plantilla_json
       
       prueba_plantilla_json() # para crear variables que también usamos aquí

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
       
       render html: "Lo recibido es: "+params.to_s+"<br>Por otro lado la salida es "+ plantilla_completa.to_json #"plantilla_completa.to_s
   end
    
end