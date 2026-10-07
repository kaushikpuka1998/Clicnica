class User < ApplicationRecord
  ROLES = %w[admin doctor patient].freeze

  has_secure_password
  has_one :doctor, dependent: :destroy, autosave: true
  has_one :patient, dependent: :destroy, autosave: true

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validates :role, inclusion: { in: ROLES }
end
