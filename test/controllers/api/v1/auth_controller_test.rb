require "test_helper"

class Api::V1::AuthControllerTest < ActionDispatch::IntegrationTest
  def register(user, profile = {})
    post api_v1_auth_register_path, params: { user: user.merge(profile) }, as: :json
  end

  def user_params(role)
    { name: "New #{role}", email: "new-#{role}@example.com", password: "secret123",
      password_confirmation: "secret123", role: role }
  end

  test "registering a doctor creates the doctor profile" do
    assert_difference [ "User.count", "Doctor.count" ], 1 do
      register user_params("doctor"), { phone: "999", specialization: "Cardiology" }
    end
    assert_response :created
    assert_equal "Cardiology", response.parsed_body.dig("doctor", "specialization")
    assert_nil response.parsed_body["password_digest"]
  end

  test "registering a patient creates the patient profile" do
    assert_difference [ "User.count", "Patient.count" ], 1 do
      register user_params("patient"), { phone: "999", dob: "1990-01-01", gender: "female" }
    end
    assert_response :created
    assert_equal "female", response.parsed_body.dig("patient", "gender")
  end

test "a doctor without phone or specialization saves nothing and lists both" do
  assert_no_difference [ "User.count", "Doctor.count" ] do
    register user_params("doctor")
  end
  assert_response :unprocessable_entity
  assert_equal [ "Doctor phone can't be blank", "Doctor specialization can't be blank" ],
               response.parsed_body["errors"]
end

test "a patient without date of birth saves nothing" do
  assert_no_difference [ "User.count", "Patient.count" ] do
    register user_params("patient"), { phone: "999", gender: "female" }
  end
  assert_response :unprocessable_entity
  assert_equal [ "Patient date of birth can't be blank" ], response.parsed_body["errors"]
end
end
