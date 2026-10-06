class Api::V1::BaseController < ApplicationController
  skip_forgery_protection
  before_action :authenticate_user!

  private

  def authenticate_user!
    header = request.headers['Authorization']
    if header.blank?
      return render json: {
        error: 'Unauthorized'
      }, status: :unauthorized
    end

    token = header.split(" ").last

    begin
      decoded_token = JwtService.decode(token)
      user_id = decoded_token["user_id"]

      @current_user = User.find(user_id)
    rescue JWT::ExpiredSignature
      render json: {
        error: "Expired token"
      }, status: :unauthorized

    rescue JWT::DecodeError
      render json: {
        error: "Invalid token"
      }, status: :unauthorized

    rescue ActiveRecord::RecordNotFound
      render json: {
        error: "User not Found"
      }, status: :not_found
    end
  end

  private

  def current_user
    @current_user
  end
end
