class Place < ApplicationRecord
  has_many :place_admins
  has_many :users, through: :place_admins
  has_many :bookings
  has_many :booking_requests
end
