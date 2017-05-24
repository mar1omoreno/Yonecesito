class ClientepasswordsController < Devise::PasswordsController
    def new
        @esconder_botones_login_entrar = true
        logger.info "ejecuta passwordscontroller new cliente"
        super
    end
    def edit
        @esconder_botones_login_entrar = true
        logger.info "ejecuta passwordscontroller new cliente"
        super
    end
end
