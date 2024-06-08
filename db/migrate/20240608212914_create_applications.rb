class CreateApplications < ActiveRecord::Migration[7.1]
  def change
    create_table :applications do |t|
      t.binary :token, null: false, limit: 16
      t.string :name, null: false
      t.index [:token], name: :application_token_index, unique: true
      t.timestamps
    end
  end
end
