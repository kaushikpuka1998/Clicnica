class AuthenticationMiddleware
  PUBLIC_PATHS = %w[/up /api/v1/auth/login /api/v1/auth/register].freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    Rails.logger.info("Request: #{request.request_method} #{request.path}")
    if !PUBLIC_PATHS.include?(request.path) && request.get_header("HTTP_AUTHORIZATION").blank?
      return [401, { "content-type" => "application/json" }, [{ error: "Unauthorized" }.to_json]]
    end

    @app.call(env)
  end
end
