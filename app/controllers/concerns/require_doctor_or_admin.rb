# frozen_string_literal: true
module RequireDoctorOrAdmin
  extend ActiveSupport::Concern

  included do
    before_action :require_doctor_or_admin_role
  end

  private

  def require_doctor_or_admin_role
    return if current_user&.doctor? || current_user&.admin?
    render json: { errors: ["Not authorized"] }, status: :forbidden
  end

end

