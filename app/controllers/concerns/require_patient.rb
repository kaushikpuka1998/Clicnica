# frozen_string_literal: true

module RequirePatient
  extend ActiveSupport::Concern
  included do
    before_action :require_patient_role
  end

  private

  def require_patient_role
    return if current_user&.patient
    render json: { errors: ["Not authorized"] }, status: :forbidden
  end
end

