class Doctor < ApplicationRecord
  belongs_to :user
  has_many :appointments

  validates :phone, :specialization, presence: true
end
