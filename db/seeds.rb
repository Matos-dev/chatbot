# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
require 'date'
today = Date.today

1.upto(15) do
  Client.create! name: Faker::FunnyName.name, rut: Faker::ChileRut.full_rut, email: Faker::Internet.email
end

Client.all.each do |client|
  today.upto(today + 30.days) do |date|
    Deposit.create! amount: Faker::Base.rand_in_range(0, 100000).round(2), deposit_date: date, client: client
  end
end

