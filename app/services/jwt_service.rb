class JwtService
  SECRET_KEY = Rails.application.secret_key_base

  ALGORITHM = "HS512"

  def self.encode(payload)
    payload = payload.merge(exp: 24.hours.from_now.to_i)

    JWT.encode(payload, SECRET_KEY, ALGORITHM)
  end

  def self.decode(token)
    JWT.decode(token, SECRET_KEY, true, { algorithm: ALGORITHM }).first
  end
end
