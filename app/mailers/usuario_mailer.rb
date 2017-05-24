class UsuarioMailer < ActionMailer::Base
  default from: "info@yonecesito.mx"
  
  #Debe enviar el correo con vista en views/usuario_mailer/verificacion_correo_profesionista
  def verificacion_correo_profesionista(profesionista)
    profesionista.codigo_verificacion_email = SecureRandom.uuid #=> "1ca71cd6-08c4-4855-9381-2f41aeffe59c"
    profesionista.save
    
    @url = url_for :only_path => false, :escape =>false, :controller => 'inicio', :action => 'validar_email_profesionista', 
          :codigo_verificacion_email =>profesionista.codigo_verificacion_email, :id => profesionista.id
    #@url = config.+@url
    logger.info "El url a enviar por correo es:"+@url
    mail(to: profesionista.email, subject:"Verificación de correo")
  end
  
  #Debe enviar el correo con vista en views/usuario_mailer/verificacion_correo_cliente
  def verificacion_correo_cliente(cliente)
    cliente.codigo_verificacion_email = SecureRandom.uuid #=> "1ca71cd6-08c4-4855-9381-2f41aeffe59c"
    cliente.save
    
    @url = url_for :only_path => false, :escape =>false, :controller => 'inicio', :action => 'validar_email_cliente', 
          :codigo_verificacion_email =>cliente.codigo_verificacion_email, :id => cliente.id
    #@url = config.+@url
    logger.info "El url a enviar por correo es:"+@url
    mail(to: cliente.email, subject:"Verificación de correo")
  end
  
  # Envía un correo en vista views/usuario_mailer/contratado
  def contratado(id_profesionista)
    profesionista = Profesionista.find(id_profesionista)
    @nombre = (profesionista.nombre_completo || "").titleize
    logger.info "Se enviará correo de contratación"
    mail(to: profesionista.email, subject: "Has sido contratado" )
  end
  
  # Envía un correo en vista views/usuario_mailer/nuevo_mensaje
  def nuevo_mensaje(id_cliente)
    cliente = Cliente.find(id_cliente)
    if !cliente.email.present? # Sucede con clientes de Facebook que no comparten el correo
      logger.info "Cliente #{id_cliente} no tiene correo para enviarle nuevo_mensaje"
      return
    end
    @nombre = (cliente.nombre_completo || "").titleize
    logger.info "Se enviará correo de nuevo mensaje"
    mail(to: cliente.email, subject: "Has recibido un nuevo mensaje" )
  end
  
end
