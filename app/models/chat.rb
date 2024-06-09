class Chat < ApplicationRecord
    has_many :messages, foreign_key: :chat_id, dependent: :delete_all
    belongs_to :application, foreign_key: :application_id
end
