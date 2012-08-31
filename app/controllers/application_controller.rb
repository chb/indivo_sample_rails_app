class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def set_consumer
    # create an OAuth consumer
    @consumer = OAuth::Consumer.new INDIVO_CONFIG[:consumer_key], INDIVO_CONFIG[:consumer_secret], {:site => INDIVO_CONFIG[:server]}
  end
  
end
