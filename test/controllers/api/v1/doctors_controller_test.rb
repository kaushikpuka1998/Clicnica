require "test_helper"

class Api::V1::DoctorsControllerTest < ActionDispatch::IntegrationTest
  test "index pages through every doctor once using the cursor" do
    3.times { |i| Doctor.create!(name: "Doc #{i}") }
    user = User.create!(name: "Admin", email: "admin@example.com", password: "secret123", role: "admin")
    headers = { "Authorization" => "Bearer #{JwtService.encode(user_id: user.id)}" }

    seen = []
    cursor = nil
    loop do
      get api_v1_doctors_path, params: { limit: 2, cursor: cursor }.compact, headers: headers
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
  user = User.create!(name: "Admin", email: "admin@example.com", password: "secret123", role: "admin")
  get api_v1_doctors_path, params: { cursor: "42" },
      headers: { "Authorization" => "Bearer #{JwtService.encode(user_id: user.id)}" }

  assert_response :bad_request
end
end
