class Api::V1::AuthController < ApplicationController
  def register
    user = RegisterUser.new(register_params, profile_params).call

    render json: user.as_json(except: :password_digest, include: %i[doctor patient]), status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  def login
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      token = JwtService.encode({ user_id: user.id })
      render json: {
        message: "Logged in",
        token: token,
        user: user.as_json(except: :password_digest)
      }, status: 200
    else
      render json: {
        errors: [ "Invalid email or password" ]
      }, status: :unauthorized
    end
  end

  private

  def register_params
    params.require(:user).permit(
      :name,
      :email,
      :password,
      :password_confirmation,
      :role
    )
  end

  def profile_params
    params.require(:user).permit(:phone,
                                 :specialization,
                                 :dob,
                                 :gender,
                                 :name,
                                 :email,
                                 :password,
                                 :password_confirmation,
                                 :role)
  end
end
