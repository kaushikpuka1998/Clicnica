class Api::V1::DoctorsController < Api::V1::BaseController
  include RequireDoctorOrAdmin

  def index
    render_paginated(Doctor.all)
  end

  def show
    doctor = Doctor.where(id: params[:id]).last

    if doctor.nil?
      render json: { data: "No Doctor Found" }
    else
      render json: doctor
    end
  end

  def create
    doctor = Doctor.new(doctor_params)

    if doctor.save
      render json: doctor, status: :created
    else
      render json: { errors: doctor.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def doctor_params
    params.require(:doctor).permit(
      :name,
      :email,
      :phone,
      :specialization
    )
  end
end
