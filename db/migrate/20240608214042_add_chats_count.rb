class AddChatsCount < ActiveRecord::Migration[7.1]
  def change
    add_column :chats, :messages_count, :integer, default: 0
  end
end
