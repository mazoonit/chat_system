class ApplicationController < ActionController::API
    rescue_from StandardError, with: :internal_server_error
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

    private

    def internal_server_error(exception)
      logger.error(exception)
      render json: { error: 'Internal Server Error' }, status: :internal_server_error
    end

    def record_not_found(exception)
      logger.error(exception)
      render json: { error: 'Resource Not Found' }, status: :not_found
    end
end
