class Api::V1::PatientsController < Api::V1::BaseController
  def show
    patient = Patient.where(id: params[:id]).last
    if patient
      render json: patient
    else
      render json: { error: "Patient not found" }
    end

  rescue StandardError => e
    Rails.logger.error(e.message)
    render json: {
      error: "Internal Server Error"
    }, status: :internal_server_error
  end

  def index
    patients = Patient.all
    render json: patients, status: :ok
  rescue StandardError => e
    Rails.logger.error(e.message)
    render json: {
      error: "Internal Server Error"
    }, status: :internal_server_error
  end

  def create
    patient = Patient.new(patient_params)
    if patient.save
      render json: patient, status: :created
    else
      render json: patient.errors, status: :unprocessable_entity
    end
  end

  private

  def patient_params
    params.require(:patient).permit(
      :name,
      :email,
      :phone,
      :dob,
      :gender
    )
  end
end
