# frozen_string_literal: true

# include RequireAdmin in a controller under Api::V1::BaseController to make every action admin-only.
# Runs after BaseController#authenticate_user!, so current_user is already set.
module RequireAdmin
  extend ActiveSupport::Concern

  included do
    before_action :require_admin!
  end

  private

  def require_admin!
    return if current_user&.admin?

    render json: { errors: ["Not authorized"] }, status: :forbidden
  end
end
