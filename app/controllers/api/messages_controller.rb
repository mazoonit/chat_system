class Api::MessagesController < ApplicationController
    before_action :set_chat
    EXCEPT = ['id', 'application_id', 'chat_id']
    def index
        messages = Message.where(chat_id: @chat_id)
        render json: messages.as_json(except: EXCEPT)
    end

    def show
        message = Message.find_by!(chat_id: @chat_id, number: params[:message_number])
        render json: message.as_json(except: EXCEPT)
    rescue ActiveRecord::RecordNotFound
        render json: { error: "Resource not found" }, status: :not_found
    end

    def create
        new_message_number = ChatService.get_new_message_number(params[:application_token], @application_id, @chat_id).to_i
        if !new_message_number
            render json: { error: "Internal Server Error!" }, status: :internal_server_error
            return
        end

        new_message = Message.new(number: new_message_number, body: params[:body], chat_id: @chat_id)
        puts @chat_id
        puts @application_id
        puts new_message

        Publisher.publish(queue_name: "messages", payload: new_message.to_json)

        render json: new_message_number
    rescue => e
        puts e
        render json: { error: "Internal Server Error." }, status: :internal_server_error
    end

    def update
        message = Message.find_by!(chat_id: @chat_id, number: params[:message_number])
        message.body = params[:body]
        message.save!
        render json: message.as_json(except: EXCEPT)
    rescue => e
        puts e
        render json: { error: "Internal Server Error." }, status: :internal_server_error
    end

    def destroy
        message = Message.find_by!(chat_id: @chat_id, number: params[:message_number])
        message.destroy
        # take care of the case that someone deletes message before It's even in the db.
        head :ok 
    rescue ActiveRecord::RecordNotFound
        render json: { error: "Resource not found" }, status: :not_found
    rescue
        render json: { error: "Internal Server Error." }, status: :internal_server_error
    end

    private
    
    def set_chat
        @application_id = ApplicationService.get_application_id_by_token(params[:application_token])
        @chat_id = ChatService.get_chat_id(params[:application_token], @application_id, params[:chat_number])
        render json: { error: "Resource not found" }, status: :not_found if !@application_id
    rescue => e
        puts e
        render json: { error: "Internal Server Error." }, status: :internal_server_error
    end
end