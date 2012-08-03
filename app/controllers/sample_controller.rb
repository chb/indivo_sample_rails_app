require 'oauth'

class SampleController < ApplicationController
  before_filter :set_consumer
  
  def start_auth
    # end point for the "index" registered in the app's manifest. 
    
    # clear out session
    reset_session
    
    #save off the record_id and oauth_params
    session[:record_id] = params[:record_id]
    session[:oauth_params] = OAuth::Helper.parse_header(params["oauth_header"])
    
    # we now let the user choose which style of authentication they want to use
    render "choose_authentication"
  end
  
  def choose_authentication
  end
  
  def oauth_authentication
    # Traditional OAuth
    # http://docs.indivohealth.org/en/v2.0.0/authentication.html#indivo-oauth
    
    session[:authentication_type] = "Traditional OAuth"
    request_token_params = {}
    record_id = session[:record_id]

    if record_id
      # scope requests to a given record_id
      request_token_params[:indivo_record_id] = record_id
    end
    
    # retrieve and store a request token
    request_token = @consumer.get_request_token({:oauth_callback => 'oob'}, request_token_params)
    session[:request_token] = {:token => request_token.token, :secret => request_token.secret}

    # redirect the user to the authorization url
    redirect_to "http://sandbox.indivohealth.org/oauth/authorize?oauth_token=#{request_token.token}"
  end

  def after_auth
    # end point for the "oauth_callback_url" registered in the app's manifest
    request_token = OAuth::RequestToken.new(@consumer, session[:request_token][:token], session[:request_token][:secret])

    # verify that the returned token matches
    if params['oauth_token'] != nil and request_token.token != params['oauth_token']
      render :text => "tokens do not match", :status => 500
      return
    end
    
    # exchange request token for an access token
    access_token = request_token.get_access_token({:oauth_verifier => params['oauth_verifier']})
    save_access_token access_token
    
    redirect_to root_path
  end
    
  def smart_rest
    # SMART REST style authentication
    # http://docs.indivohealth.org/en/v2.0.0/authentication.html#pre-generated-rest-authentication
    # http://dev.smartplatforms.org/howto/build_a_rest_app/ 
    
    session[:authentication_type] = "SMART REST"
    
    oauth_params = session[:oauth_params]
    record_id = oauth_params["smart_record_id"]
    token = oauth_params['smart_oauth_token']
    secret = oauth_params['smart_oauth_token_secret']
    
    access_token = OAuth::AccessToken.new(@consumer, token, secret)
    save_access_token access_token

    redirect_to root_path
  end
   
  def smart_connect
    # SMART connect style authentication
    # http://docs.indivohealth.org/en/v2.0.0/authentication.html#in-browser-connect-authentication
    # http://dev.smartplatforms.org/howto/build_a_smart_app/
    
    session[:authentication_type] = "SMART Connect"
    
    # the app is purely JavaScript, so render the view that contains it
    render "connector_sample"
  end 
    
  def index
    @model_list = { "allergies" => "Allergies",
                    "demographics" => "Demographics",
                    "encounters" => "Encounters",
                    "fulfillments" => "Fulfillments",
                    "immunizations" => "Immunizations",
                    "lab_results" => "Lab Results",
                    "medications" => "Medications",
                    "problems" => "Problems",
                    "vital_signs" => "Vital Signs" 
                  }
    
    # check for valid model_name param; default to allergies
    @model_name = params[:model_name] || "allergies" 
    @model_name = (@model_list.has_key?(@model_name) ? @model_name : "allergies")
    
    # read token and record_id from session
    record_id = session[:record_id]
    access_token = session[:access_token]
    
    # only demographics does not have a trailing slash
    if @model_name != "demographics"
      url = "/records/#{record_id}/#{@model_name}/"
    else
      url = "/records/#{record_id}/#{@model_name}"
    end
    
    # read the problems and display as XML
    response = access_token.get url
    @results = response.body
  end
  
  def save_access_token (access_token)
    session[:access_token] = access_token
  end
end
