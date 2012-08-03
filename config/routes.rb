Sample::Application.routes.draw do
  root :to => 'sample#index'

  # "index" registered with Indivo as part of the app manifest
  match 'start_auth' => 'sample#start_auth'
  
  # "oauth_callback_url" registered with Indivo as part of the app manifest
  match 'after_auth' => 'sample#after_auth'

  # the three different authentication methods supported by Indivo
  match 'authenticate/oauth' => 'sample#oauth_authentication'
  match 'authenticate/smart_rest' => 'sample#smart_rest'
  match 'authenticate/smart_connect' => 'sample#smart_connect'

  match 'choose' => 'sample#choose_authentication'

end
