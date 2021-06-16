class User < ApplicationRecord
  has_many :place_admins
  has_many :places, through: :place_admins
  has_many :booking_requests
  has_many :bookings
end
