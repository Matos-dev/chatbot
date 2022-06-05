class UniquenessDepositDate < ActiveRecord::Migration[6.0]
  def change
    add_index :deposits, %i[client_id deposit_date], unique: true
  end
end
