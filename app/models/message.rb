class Message < ApplicationRecord
    belongs_to :chat, foreign_key: :chat_id
end
