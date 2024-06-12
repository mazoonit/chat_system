class Api::ApplicationsController < ApplicationController
    EXCEPT = ['id', 'created_at', 'updated_at']
    before_action :get_application_by_token, only:[:show, :update, :destroy]

    def index
        apps = Application.all.page(params[:page] || 1).per(params[:limit] || 10)
        render json: apps.as_json(except: EXCEPT)
    end

    def show
        render json: @application.as_json(except: EXCEPT)
    end

    def create
        app = Application.new(name: create_application_params[:name])
        if app.save!
            render json: app.as_json(except: EXCEPT)
        else
            render json: app.errors, status: :unprocessable_entity
        end
    end

    def update
        @application.name = update_application_params[:name]
        if @application.save!
            render json: @application.as_json(except: EXCEPT)
        else
            render json: @application.errors, status: :unprocessable_entity
        end
    end

    def destroy
        @application.destroy
        head :ok 
    end

    private

    def create_application_params
        params.require(:application).permit(:name)
    end

    def update_application_params
        params.require(:application).permit(:name)
    end

    def get_application_by_token
        application_id = $redis.get(params[:token])
        if application_id
            @application = Application.find_by!(id: application_id) # a bit faster since It's the clustered index
        else
            @application = Application.find_by!(token: params[:token])
            $redis.set(params[:token], @application.id)
            # I could've cached the entire app object, but I'm trying to minimize RAM usage since It's costy.
        end
    end
end