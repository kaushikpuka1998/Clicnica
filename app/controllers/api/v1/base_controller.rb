class Api::V1::BaseController < ApplicationController
  skip_forgery_protection
  before_action :authenticate_user!

  private

  def authenticate_user!
    header = request.headers["Authorization"]
    if header.blank?
      return render json: {
        error: "Unauthorized"
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

  def current_user
    @current_user
  end

  # Cursor pagination on the primary key: ?limit=20&cursor=<next_cursor from previous page>
  # The cursor is the last id, encrypted so clients cannot read or forge it.
  # ponytail: id-only cursor + id order; encrypt [sort_key, id] instead if lists need other sort orders
  CURSOR_ENCRYPTOR = ActiveSupport::MessageEncryptor.new(
    Rails.application.key_generator.generate_key("pagination_cursor", 32), url_safe: true
  )

  def render_paginated(scope)
    limit = params.fetch(:limit, 2).to_i.clamp(1, 100)

    if params[:cursor].present?
      last_id = CURSOR_ENCRYPTOR.decrypt_and_verify(params[:cursor])
      scope = scope.where("#{scope.table_name}.id > ?", last_id)
    end

    records = scope.order(:id).limit(limit + 1).to_a
    has_more = records.size > limit
    records = records.first(limit)
    next_cursor = CURSOR_ENCRYPTOR.encrypt_and_sign(records.last.id) if has_more

    render json: { data: records, next_cursor: next_cursor, has_more: has_more }
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    render json: { error: "Invalid cursor" }, status: :bad_request
  end
end
