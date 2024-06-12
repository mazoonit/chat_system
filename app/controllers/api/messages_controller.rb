class Api::MessagesController < ApplicationController
    before_action :set_chat
    EXCEPT = ['id', 'application_id', 'chat_id']
    def index
        if params[:query].present?
            messages = Message.where(chat_id: @chat_id).search(params[:query], @chat_id).page(params[:page] || 1).per(params[:limit] || 10)
        else
            messages = Message.where(chat_id: @chat_id).page(params[:page] || 1).per(params[:limit] || 10)
        end      
        render json: messages.as_json(except: EXCEPT)
    end

    def show
        message = Message.find_by!(chat_id: @chat_id, number: params[:message_number])
        render json: message.as_json(except: EXCEPT)
    end

    def create
        new_message_number = ChatService.get_new_message_number(params[:application_token], @application_id, @chat_id).to_i
        if !new_message_number
            logger.error("Failed to assign chat number")
            render json: { error: "Internal Server Error." }, status: :internal_server_error
            return
        end

        new_message = Message.new(number: new_message_number, body: params[:body], chat_id: @chat_id)

        Publisher.publish(queue_name: "messages", payload: new_message.to_json)

        render json: new_message_number
    end

    def update
        message = Message.find_by!(chat_id: @chat_id, number: params[:message_number])
        message.body = params[:body]
        message.save!
        render json: message.as_json(except: EXCEPT)
    end

    def destroy
        message = Message.find_by!(chat_id: @chat_id, number: params[:message_number])
        message.destroy
        $redis.sadd("updated_chats", @chat_id)
        head :ok 
    end

    private
    
    def set_chat
        @application_id = ApplicationService.get_application_id_by_token(params[:application_token])
        @chat_id = ChatService.get_chat_id(params[:application_token], @application_id, params[:chat_number])
        render json: { error: "Resource not found" }, status: :not_found if !@application_id
    end
end