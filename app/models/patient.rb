class Patient < ApplicationRecord
  belongs_to :user
  has_many :appointments

  validates :phone, :dob, :gender, presence: true
end
