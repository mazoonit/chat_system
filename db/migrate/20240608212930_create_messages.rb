class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.integer :number, null: false
      t.integer :chat_id, null: false
      t.text :body, null: false
      t.index [:chat_id, :number], name: :chat_id_and_message_number_index
      t.timestamps
    end
  end
end
