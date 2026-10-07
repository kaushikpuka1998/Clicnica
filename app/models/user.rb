class User < ApplicationRecord
  has_secure_password

  enum :role, {
    admin: "admin",
    doctor: "doctor",
    patient: "patient"
  }, validate: true
  has_one :doctor, dependent: :destroy, autosave: true
  has_one :patient, dependent: :destroy, autosave: true

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
end
