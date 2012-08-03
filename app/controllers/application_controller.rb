class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def set_consumer
    # create an OAuth consumer with the standard demo credentials for the Indivo Sandbox (http://sandbox.indivohealth.org/about)
    # hard coded here for the sake of demo simplicity
    @consumer = OAuth::Consumer.new 'sampleweb@apps.indivo.org', 'yourwebapp', {:site => 'http://sandbox.indivohealth.org:8000'}
  end
  
end
