class CreateDeposits < ActiveRecord::Migration[6.0]
  def change
    create_table :deposits do |t|
      t.decimal :amount, precision: 8, scale: 2
      t.date :deposit_date
      t.belongs_to :client, null: false, foreign_key: true

      t.timestamps
    end
  end
end
