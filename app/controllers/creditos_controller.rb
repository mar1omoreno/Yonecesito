class CreditosController < ApplicationController
    include ERB::Util #para usar url_encode en validarTransaccion()

    protect_from_forgery
    before_action :validar_login_profesionista #heredado en application_controller.rb
    
    # INFORMACIÓN DE PADEMOBILE
    ID_USUARIO_PADEMOBILE = "2450825" # Testing con usuario 244
    SECRET_PADEMOBILE = "3a8ahc3xcsgliwz" # Código secreto de Pademobile para FIRMAR con hash de sha128. Testing con sfe23rK_sds2$-dfdw2
    URL_PADEMOBILE_COMPRAR = "https://www.pademobile.com:810/comprar" #Producción: https://www.pademobile.com:810/comprar  Testing: https://desarrollo.pademobile.com/comprar
    # En servidor testing el usuario para hacer compras en PadeMobile es País:España, Tel: 607616071, Pin: 0000, Confirmación SMS: 0000

    # VISTA Lista de planes disponibles
    def index
    end
    
    # VISTA con confirmación de inicio de compra de créditos
    # En params recibe :id_plan para generar la transacción adecuada
    def iniciar_compra
        @plan = Credito::PLANES.detect {|u| u[:id] == params[:id_plan].to_i }
        if @plan.nil?
            redirect_to creditos_index_path
            return
        end
        credito = Credito.create(id_profesionista: current_profesionista.id, fecha_adquisicion: Time.now, 
                creditos_adquiridos: @plan[:creditos], costo: @plan[:costo] )
        @url_compra = crear_url_pademobile(@plan, credito.id)
        # Por cambios del cliente, redireccionamos directo a sitio pademobile
        redirect_to @url_compra
    end

    # Genera un url de compra firmado a pademobile
    # plan es un hash de la lista PLANES en modelo Credito
    # id_credito es el id de un registro en base de datos en tabla creditos que servirá como id de transacción
    def crear_url_pademobile(plan, id_credito)
        url_retorno = url_for :controller => 'creditos', :action => 'procesar_compra'
        parametros = {:descripcion => plan[:descripcion_pademobile] ,
            :id_usuario => ID_USUARIO_PADEMOBILE,
            :url => url_retorno, #"https://demo-project-axel20000.c9.io/php/index.php",
            :pais => "MX",
            :id_local_transaccion => id_credito, 
            :telefono => "", 
            :importe => plan[:costo]
        }
        datos = crear_query_string(parametros) #'descripcion=Ha+comprado+usted+algo+bonito&id_usuario=244&url=https%3A%2F%2Fdesarrollo.pademobile.com%2Ffake-commerce%2Fback%2F&pais=MX&id_local_transaccion=valor&telefono=&importe=10'
        firma = firmar_hmac_sha1(datos, SECRET_PADEMOBILE)
        
        queryStringFinal = "?"+datos+"&firma="+firma
        return URL_PADEMOBILE_COMPRAR + queryStringFinal
    end

    # Genera un querystring con parámetros HTTP correctos según valores en hash
    # Ej: hash {a: 'valora', b: 'valorb'} retorna a=valora&b=valorb
    # La función escapa valores en caso de ser necesario
    def crear_query_string(hash)
        #require 'uri'
        return URI.encode_www_form(hash)
    end

    # Codifica/firma contenido de data con secret usando hmac de sha128 
    def firmar_hmac_sha1(data, secret)
        #require 'base64'
        #require 'openssl'
        hmac = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), secret.encode("ASCII"), data.encode("ASCII"))
        return hmac
    end


    # VISTA Recibe de pademobile resultados de transacciones de compra
    def procesar_compra
        logger.info "La validez de la transacción es: #{validarTransaccion(SECRET_PADEMOBILE)}"
        if validarTransaccion(SECRET_PADEMOBILE)
            @resultado = "transacción válida"
            if params["status"] == "true"
                # Validamos si el crédito ya había sido pagado
                @credito = Credito.find(params["id_local_transaccion"].to_i)
                if @credito.valido == 0
                    # Sumamos créditos
                    current_profesionista.creditos += @credito.creditos_adquiridos
                    current_profesionista.save
                    @credito.valido = 1
                    @credito.codtran_pademobile = params["codtran"]
                    @credito.save
                    @resultado = "Su compra ha sido procesada exitosamente"
                else
                    # Este crédito ya había sido registrado (ej, si usuario hace F5 en esta misma vista)
                    @resultado = "Esta compra ya está validada"
                end
            else
                @resultado = "No fue posible procesar su compra: " + params["message"]
            end
        else
            # transacción ILEGAL!!!
            @resultado = "Transacción ilegal: La firma de la transacción y la información recibida no coinciden"
        end
        
        #arreglo = URI.decode_www_form(datos) #puts arreglo.assoc("descripcion").last
        #arreglo = Hash[*arreglo.flatten] #.symbolize_keys
        #logger.info arreglo["id_local_transaccion"]
    end

    # Proceso inverso con respuesta. Valida que los datos recibidos en querystring firmados coincidan con la firma adjunta al querystring
    # https://demo-project-axel20000.c9.io/php/index.php?codtran=d76155046cb19d38560292fb72160f91&tipo_pago=pademobile&id_local_transaccion=valor+de+la+transaccion&sign=a64219cd1cb92f37c455c3c95714d8869c347211&status=true&message=La%20operaci%C3%B3n%20se%20ha%20realizado%20con%20%C3%A9xito
    def validarTransaccion( secret )
        # Esquema del contenido que debe tener params
        #retorno = {"codtran" => "d76155046cb19d38560292fb72160f91",
        #    "tipo_pago" => "pademobile",
        #    "id_local_transaccion" => "valor+de+la+transaccion",
        #    "sign" => "a64219cd1cb92f37c455c3c95714d8869c347211",
        #    "status" => "true",
        #    "message" => "mensajeeee"
        #}
        if params["sign"].nil?
            return false
        end
        firmaServidor = params["sign"] #"a64219cd1cb92f37c455c3c95714d8869c347211"
        firmado = "codtran="+params["codtran"]+"&tipo_pago="+params["tipo_pago"]+"&id_local_transaccion="+params["id_local_transaccion"]
        #require 'erb'
        #include ERB::Util #para usar url_encode
        firmaLocal = firmar_hmac_sha1( url_encode(firmado) , secret) #debe ser igual a firmaServidor
        return firmaLocal == firmaServidor
    end


end