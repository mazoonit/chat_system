class Api::ChatsController < ApplicationController
    before_action :set_application
    EXCEPT = ['id', 'application_id']

    def index
        chats = Chat.where(application_id: @application_id).page(params[:page] || 1).per(params[:limit] || 10)
        render json: chats.as_json(except: EXCEPT)
    end

    def show
        chat = Chat.find_by!(application_id: @application_id, number: params[:number])
        render json: chat.as_json(except: EXCEPT)
    end

    def create
        new_chat_number = ApplicationService.get_new_chat_number(@application_id, params[:application_token]).to_i
        if !new_chat_number
            logger.error("Failed to assign chat number")
            render json: { error: "Internal Server Error." }, status: :internal_server_error
            return
        end

        new_chat = Chat.new(number: new_chat_number, application_id: @application_id)

        Publisher.publish(queue_name: "chats", payload: new_chat.to_json)

        render json: new_chat_number
    end

    def destroy
        chat = Chat.find_by!(application_id: @application_id, number: params[:number])
        chat.destroy

        $redis.del("#{params[:token]}_#{params[:number]}_messages_count")
        $redis.sadd("updated_applications", @application_id)

        head :ok 
    end

    private
    
    def set_application
        @application_id = ApplicationService.get_application_id_by_token(params[:application_token])
        render json: { error: "Resource not found" }, status: :not_found if !@application_id
    end
end