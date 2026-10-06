class Api::V1::AuthController < ApplicationController
  def register
    user = User.new(register_params)

    if user.save
      render json: {
        message: "Successfully registered",
        user: user.as_json(except: :password_digest)
      }, status: 200
    else
      render json: {
        errors: user.errors.full_messages
      }, status: 422
    end
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
end
