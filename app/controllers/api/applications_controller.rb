class Api::ApplicationsController < ApplicationController
    EXCEPT = ['id']

    def index
        apps = Application.all.page(params[:page] || 1).per(params[:limit] || 10)
        render json: apps.as_json(except: EXCEPT)
    end

    def show
        app = Application.find_by!(token: params[:token])
        render json: app.as_json(except: EXCEPT)
    end

    def create
        app = Application.new(name: params[:name])
        if app.save!
            render json: app.as_json(except: EXCEPT)
        else
            render json: app.errors, status: :unprocessable_entity
        end
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
    end
end