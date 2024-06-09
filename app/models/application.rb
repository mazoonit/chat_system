class Application < ApplicationRecord
    has_many :chats, foreign_key: :application_id, dependent: :delete_all
    attribute :token, MySQLBinUUID::Type.new

    before_create :create_uuid_token

    private

    def create_uuid_token
        self.token = SecureRandom.uuid
    end
end
