class Client < ApplicationRecord
  validates :email, uniqueness: true
  validates :rut, uniqueness: true
  validates_format_of :email, with: /@/
  has_many :deposits
end
