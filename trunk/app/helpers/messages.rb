class Messages
   @messages = {
    "service.name" =>"Logo",
    "header.secondary.all" => "Todos",
    "header.secondary.show_cloud" =>"Mostrar n&uacute;vem de Tags",
    "header.secondary.submit_new_link" => "Submeter novo link",
    "header.secondary.tag_cloud" => "N&uacute;vem de Tags",
    "header.secondary.hide_cloud"=> "Esconder N&uacute;vem de Tags",
    "common.ordering" => "Ordenar",
    "common.ordering.alpha"=> "Alfabeticamente",
    "common.ordering.popular"=> "Popularidade",
    "common.hide"=> "Esconder",
    "login.login_title" => "Loggin no logo",
    "login.login.dont_have_account_yet"=>"Ainda n&atilde;o est&aacute;s registado no Logo?",
    "login.login.join_now" => "Regista-te agora",
    "login.login.why_register" => "&Eacute; gr&aacute;tis e demora apenas 1 minuto.",
    "login.login.fieldset_leggend" => "Login",
    "login.login.lost_your_password" => "Perdes-te a password?",
    "login.login.lost_your_password_your_email" => "O teu e-mail:",
    "login.login.lost_your_password_retrieve_password"=> "Recuperar Password",
    "login.login.label.email" => "Email",
    "login.login.label.password" =>"Password",
    "login.login.label.persistent_session" => "Login autom&aacute;tico neste computador?",
    "login.login.cancel_login" => "Cancelar",
    "login.login.login" => "Entrar",
    "login.login.invalid_login" => "Password e/ou email incorrecto",
    "login.login.logout" => "Logout",
    "user.join" => "Quero registar-me",
    "user.register" => "Registar novo utilizador",
    "register.have_account_already" => "Se j&aacute; est&aacute;s registado clica ",
    "register.click_here" => "aqui",
    "register.click_here.to_login" => "para entrares no Logo",
    "register.user_info" => "Informa&ccedil;&atilde;o do utilizador",
    "register.all_fields_mandatory"=>"Todos os campos s&atilde;o necess&aacute;rios",
    "register.check.availability" => "Verificar disponibilidade",
    "register.email_tip" =>"O email &eacute; utilizado para fins de identifica&ccedil;&atilde;o e autentica&ccedil;&atilde;o apenas.<br/> Nunca ser&eacute; divulgado sem autoriza&ccedil;&atilde;o.<br/>Tem de ser um <strong>email v&aacute;lido</strong>",
    "register.screen_name" => "Nome Utilizador",
    "register.check.availability_tooltip" =>"Verifica se o nome de utilizador est&aacute; dispon&iacute;vel!",
    "register.screen_name_tip" => "Este &eacute; o nome pelo qual ser&aacute; conhecido pelos outros utilizadores.<br/>O nome de utilizador &eacute; p&uacute;blico<br/>Tem de ter entre 4 e 15 caracteres, sem espa&ccedil;os.",
    "login.login.label.password.confirm" => "Confirma&ccedil;&atilde;o Password",
    "register.password_tip" => "M&iacute;nimo 6 caract&eacute;res",
    "common.continue" => "Continuar",
    "register.read_the_terms" => "Eu li e aceito os termos",
    "form.validation.error" => "Ocorreram alguns erros durante a valida&ccedil;&atilde;o dos dados.<br/>Por favor verifica e corrige os erros!"
    
    
    
    
    
   }.freeze
   
   def self.messages()
     @messages
   end
end
