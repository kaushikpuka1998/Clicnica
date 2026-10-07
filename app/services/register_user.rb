# frozen_string_literal: true

# Creates a user and, for doctor/patient roles, their profile.
# User and profile are validated together (autosave on the has_one), so the
# 422 lists every missing field at once, and both rows are saved in one transaction.
class RegisterUser
  PROFILE_FIELDS = {
    "doctor" => %i[phone specialization],
    "patient" => %i[phone dob gender]
  }.freeze

  def initialize(user_params, profile_params = {})
    @user_params = user_params
    @profile_params = profile_params
  end

  def call
    user = User.new(@user_params)
    build_profile(user)
    user.save!
    user
  end

  private

  def build_profile(user)
    fields = PROFILE_FIELDS[user.role] or return

    attrs = @profile_params.to_h.symbolize_keys.slice(*fields).merge(name: user.name, email: user.email)
    user.public_send("build_#{user.role}", attrs)
  end
end
