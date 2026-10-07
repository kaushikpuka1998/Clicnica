require "test_helper"

class Api::V1::DoctorsControllerTest < ActionDispatch::IntegrationTest
  def auth_headers(user)
    { "Authorization" => "Bearer #{JwtService.encode(user_id: user.id)}" }
  end

  def admin
    @admin ||= User.create!(name: "Admin", email: "admin@example.com", password: "secret123", role: "admin")
  end

  test "index pages through every doctor once using the cursor" do
    3.times do |i|
      user = User.create!(name: "Doc #{i}", email: "doc#{i}@example.com", password: "secret123", role: "doctor")
      Doctor.create!(name: "Doc #{i}", phone: "1", specialization: "GP", user: user)
    end

    seen = []
    cursor = nil
    loop do
      get api_v1_doctors_path, params: { limit: 2, cursor: cursor }.compact, headers: auth_headers(admin)
      assert_response :success
      body = response.parsed_body
      assert_operator body["data"].size, :<=, 2
      seen.concat(body["data"].map { |d| d["id"] })
      cursor = body["next_cursor"]
      assert_equal cursor.present?, body["has_more"]
      break unless body["has_more"]
    end

    assert_equal Doctor.order(:id).ids, seen
  end

  test "index rejects a tampered cursor" do
    get api_v1_doctors_path, params: { cursor: "42" }, headers: auth_headers(admin)

    assert_response :bad_request
  end

  test "non-admin users get 403" do
    get api_v1_doctors_path, headers: auth_headers(users(:doctor_one))

    assert_response :forbidden
    assert_equal [ "Not authorized" ], response.parsed_body["errors"]
  end
end
