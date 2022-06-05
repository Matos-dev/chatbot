class AddAmounToOrder < ActiveRecord::Migration[6.0]
  def change
    add_column :order_papers, :amount, :decimal
  end
end
