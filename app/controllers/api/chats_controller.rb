class Api::ChatsController < ApplicationController
    before_action :set_application
    EXCEPT = ['id']
    def index
        chats = Chat.where(application_id: @application_id)
        render json: chats.as_json(except: EXCEPT)
    end

    def show
        chat = Chat.find_by!(application_id: @application_id, chat_number: params[:chat_number])
        render json: chat.as_json(except: EXCEPT)
    rescue ActiveRecord::RecordNotFound
        render json: { error: "Resource not found" }, status: :not_found
    end

    def create
        new_chat_number = ApplicationService.get_new_chat_number(@application_id, params[:application_token]).to_i
        if !new_chat_number
            render json: { error: "No chat number?" }, status: :internal_server_error
            return
        end

        new_chat = Chat.new(number: new_chat_number, application_id: @application_id)

        Publisher.publish(queue_name: "chats", payload: new_chat.to_json)

        render json: new_chat_number
    rescue => e
        puts e
        render json: { error: "Internal Server Error." }, status: :internal_server_error
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

    private
    
    def set_application
        @application_id = ApplicationService.get_application_id_by_token(params[:application_token])
        render json: { error: "Resource not found" }, status: :not_found if !@application_id
    rescue => e
        puts e
        render json: { error: "Internal Server Error." }, status: :internal_server_error
    end
end