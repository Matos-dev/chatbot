class CreateClients < ActiveRecord::Migration[6.0]
  def change
    create_table :clients do |t|
      t.string :name
      t.string :email
      t.string :rut

      t.timestamps
    end
  end
end
