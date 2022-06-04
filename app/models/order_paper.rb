class OrderPaper < ApplicationRecord
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }, presence: true
  belongs_to :client
end
