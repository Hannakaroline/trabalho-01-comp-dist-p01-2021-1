class BookingRequest < ApplicationRecord
  belongs_to :place
  belongs_to :user
  belongs_to :booking, optional: true
end
