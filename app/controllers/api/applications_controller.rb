class Api::ApplicationsController < ApplicationController
    EXCEPT = ['id']
    def index
        apps = Application.all
        render json: apps.as_json(except: EXCEPT)
    end

    def show
        app = Application.find_by!(token: params[:token])
        render json: app.as_json(except: EXCEPT)
    rescue ActiveRecord::RecordNotFound
        render json: { error: "Resource not found" }, status: :not_found
    end

    def create
        app = Application.new(name: params[:name])
        if app.save!
            render json: app.as_json(except: EXCEPT)
        else
            render json: app.errors, status: :unprocessable_entity
        end
    rescue
        render json: {error: "Internal Server Error"}, status: :internal_server_error
    end

    def update
        app = Application.find_by!(token: params[:token])
        app.name = params[:name]
        if app.save!
            render json: app.as_json(except: EXCEPT)
        else
            render json: app.errors, status: :unprocessable_entity
        end
    end

    def destroy
        app = Application.find_by!(token: params[:token])
        app.destroy
        head :ok 
    rescue ActiveRecord::RecordNotFound
        render json: { error: "Resource not found" }, status: :not_found
    rescue
        render json: { error: "Internal Server Error." }, status: :internal_server_error
    end
end