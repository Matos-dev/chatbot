class CreateOrderPapers < ActiveRecord::Migration[6.0]
  def change
    create_table :order_papers do |t|
      t.integer :quantity
      t.string :delivery_address
      t.belongs_to :client, null: false, foreign_key: true

      t.timestamps
    end
  end
end
