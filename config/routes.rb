Rails.application.routes.draw do
  
  

  get 'mensajes_cliente_profesionistas/mensajes'

  devise_for :profesionistas, controllers: { 
                                      registrations: "profesionistaregistrations",  #profesionistaregistrations_controller.rb
                                      sessions: "profesionistasessions",
                                      passwords: "profesionistapasswords"
                                     # omniauth_callbacks: "omniauth_callbacks", #omniauth_callbacks_controller.rb 
                                      }
                        # Facebook para clientes
  devise_for :clientes, controllers: {
                                      omniauth_callbacks: "omniauth_callbacks", #omniauth_callbacks_controller.rb 
                                      registrations: "clienteregistrations",  #clienteregistrations_controller.rb
                                      sessions: "clientesessions",
                                      passwords: "clientepasswords"
                                      }
 get 'dummy/index'
 get 'dummy/get_ciudades'
 post 'dummy/guardar'
 get 'dummy/prueba_plantilla_json'
 post 'dummy/guardar_prueba_plantilla_json'
 #get "/404", :to => "errors#not_found"
 
 #acciones index principal de usuarios no logeados
  get 'inicio/index'                                      
  get 'inicio/registrate'
  get 'inicio/entra'
  get 'inicio/que_es'
  get 'inicio/terminos'
  get 'inicio/politicas'
  get 'inicio/ver_profesionista'
  
  ######PARA PROFESIONISTA
  # Recolección de datos de inicio de profesionista
  get 'inicio_profesionista/index'
  get 'filtros_profesionistas/filtroA'
  get 'filtros_profesionistas/filtroB'
  post 'filtros_profesionistas/filtroB'
  get 'filtros_profesionistas/filtroC'
  post 'filtros_profesionistas/filtroC'
  post 'filtros_profesionistas/final'
  
  # Home de profesionista llamado desde InicioProfesionistaController.index
  get 'inicio_profesionista/servicios'
  
  #Búsqueda de trabajos
  get 'inicio_profesionista/buscar_trabajo'
  get 'inicio_profesionista/get_ciudades'
  
  # Panel de profesionista
  get 'inicio_profesionista/datos_basicos'
  post 'inicio_profesionista/guardar_datos_basicos'
  get 'inicio_profesionista/contacto'
  post 'inicio_profesionista/guardar_contacto'
  get 'inicio_profesionista/foto'
  patch 'inicio_profesionista/foto'
  get 'inicio_profesionista/verificaciones'
  get 'inicio/validar_email_profesionista' #En controlador público pues no requiere sesión activa
  get 'inicio_profesionista/seguridad'
  put 'inicio_profesionista/cambiar_password' #Llamado desde /seguridad
  get 'inicio_profesionista/panel_servicios'
  get 'inicio_profesionista/get_tipos_trabajo_de_categoria' #Llamado desde /panel_servicios con AJAX
  post 'inicio_profesionista/guardar_servicios'
  
  
  # Créditos
  get 'creditos/index' # Listado de créditos para comprar
  get 'creditos/iniciar_compra' # Crea transacción y url firmado para comprar en pademobile
  get 'creditos/procesar_compra' # Dirección en que pademobile regresa resultado de transacción de compra
  
  # Trabajo/Evento
  get 'trabajo_profesionista/ver'
  post 'trabajo_profesionista/cotizar'
  post 'trabajo_profesionista/enviar_mensaje'
  
  # Example resource route within a namespace:
     namespace :entidad do
       # Directs /entidad/accion1/* to Entidad::Accion1Controller
       # (app/controllers/entidad/accion1_controller.rb)
       namespace :accion1 do
        get 'vista_x'
        get 'index'
       end
     end
  ############# FIN ACCIONES EXCLUSIVAS PROFESIONISTA


  ##### PARA CLIENTE
  # Home de cliente
  get 'inicio_cliente/index'
  get 'inicio_cliente/get_ciudades' # usado en varias vistas de inicio_cliente/datos_basicos, solicitar_servicios
  
  # Panel de cliente
  get 'inicio_cliente/datos_basicos'
  post 'inicio_cliente/guardar_datos_basicos'
  get 'inicio_cliente/contacto'
  post 'inicio_cliente/guardar_contacto'
  get 'inicio_cliente/foto'
  patch 'inicio_cliente/foto'
  get 'inicio_cliente/verificaciones'
  get 'inicio/validar_email_cliente' #En controlador público pues no requiere sesión activa
  get 'inicio_cliente/seguridad'
  put 'inicio_cliente/cambiar_password' #Llamado desde /seguridad
  
  # Solicitud de servicio
  get 'inicio_cliente/categorias' #Listado de categorías de tipos de servicio
  get 'inicio_cliente/solicitar_servicios'
  post 'inicio_cliente/guardar_servicios'
  get 'inicio_cliente/ver_servicio'
  get 'inicio_cliente/mensaje_servicio'
  get 'inicio_cliente/terminar_servicio'
  post 'inicio_cliente/guardar_terminar_servicio'
  post 'inicio_cliente/guardar_evaluar_servicio'
  post 'inicio_cliente/guardar_contrato_servicio'
  post 'inicio_cliente/enviar_mensaje_servicio'
  post 'inicio_cliente/guardar_rechazo_servicio'
  
  
  
  ############# FIN ACCIONES EXCLUSIVAS CLIENTE
  
  
  
  
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'inicio#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
