class Api::V1::DoctorsController < Api::V1::BaseController

  def index
    doctors = Doctor.all
    render json: doctors
  end

  def show
    doctor = Doctor.where(id: params[:id])
    if doctor.size > 0
      render json: doctor
    else
      render json: { data: "No Doctor Found" }
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
