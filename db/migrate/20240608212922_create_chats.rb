class CreateChats < ActiveRecord::Migration[7.1]
  def change
    create_table :chats do |t|
      t.integer :number, null: false
      t.integer :application_id, null: false
      t.index [:application_id, :number], name: :application_id_and_chat_number_index
      t.timestamps
    end
  end
end
