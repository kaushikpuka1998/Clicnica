class Api::V1::AppointmentsController < Api::V1::BaseController
  def index
    render_paginated(Appointment.all)

  rescue StandardError => e
    render json: e.to_s, status: :internal_server_error
  end

  def create
    appointment = Appointment.new(appointment_params)

    if appointment.save
      render json: appointment, status: :created
    else
      render json: appointment.errors.full_messages, status: :unprocessable_entity
    end
  end

  private

  def appointment_params
    params.require(:appointment).permit(
      :patient_id,
      :doctor_id,
      :scheduled_at,
      :status,
      :reason
    )
  end
end
