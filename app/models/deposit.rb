class Deposit < ApplicationRecord
  validates :amount, numericality: { greater_than_or_equal_to: 0 }, presence: true
  belongs_to :client
  validates :client_id, uniqueness: { scope: :deposit_date }
end
