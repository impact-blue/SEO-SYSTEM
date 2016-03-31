class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

#  def error404
#    render 'error404', status: 404, formats: [:html]
#  end

#  def error500(e)
#    logger.error [e, *e.backtrace].join("\n")
#    render 'error500', status: 500, formats: [:html]
#  end


end
