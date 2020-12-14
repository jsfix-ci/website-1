require "application_system_test_case"

module Flows
  class UserRegistrationTest < ApplicationSystemTestCase
    test "user registers successfully" do
      allow_captcha_request do
        visit new_user_registration_path
        fill_in "Email", with: "user@exercism.io"
        fill_in "Username", with: "user22"
        fill_in "Password", with: "password"
        fill_in "Password confirmation", with: "password"
        click_on "Sign Up"

        assert_text "Check your email"
      end
    end

    test "user sees captcha errors" do
      allow_captcha_request do
        stub_request(:post, "https://hcaptcha.com/siteverify").
          to_return(body: { success: false }.to_json)

        visit new_user_registration_path
        fill_in "Email", with: "user@exercism.io"
        fill_in "Username", with: "user22!"
        fill_in "Password", with: "password"
        fill_in "Password confirmation", with: "password"
        click_on "Sign Up"

        assert_text "Captcha verification failed. Please try again."
      end
    end

    test "user sees registration errors" do
      allow_captcha_request do
        visit new_user_registration_path
        fill_in "Email", with: "user@exercism.io"
        fill_in "Username", with: "user22!"
        fill_in "Password", with: "password"
        fill_in "Password confirmation", with: "password"
        click_on "Sign Up"

        assert_text "Handle must have only letters, numbers, or hyphens"
      end
    end

    test "user registers via Github" do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
        provider: "github",
        uid: "111",
        info: {
          email: "user@exercism.io",
          name: "Name",
          nickname: "user22"
        }
      )
      visit new_user_registration_path
      click_on "Sign Up with GitHub"

      refute_text "Check your email"
      assert_text "Onboarding"

    ensure
      OmniAuth.config.test_mode = false
    end

    test "user sees errors when registering via Github" do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
        provider: "github",
        uid: "111",
        info: {
          email: nil,
          name: "Name",
          nickname: "user22"
        }
      )
      visit new_user_registration_path
      click_on "Sign Up with GitHub"

      assert_text "Sorry, we could not authenticate you from GitHub."

    ensure
      OmniAuth.config.test_mode = false
    end

    test "user sees errors when initial OAuth exchange fails" do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:github] = :failed

      # Check the outputter outputs an error and also
      # stop putting noise in the test logs.
      OmniAuth.config.logger.expects(:error).with("(github) Authentication failure! failed encountered.")

      visit new_user_registration_path
      click_on "Sign Up with GitHub"

      assert_text "Sorry, we could not authenticate you from GitHub."

    ensure
      OmniAuth.config.test_mode = false
    end

    private
    def allow_captcha_request
      RestClient.unstub(:post)
      stub_request(:post, "https://hcaptcha.com/siteverify").
        to_return(body: { success: true }.to_json)

      yield
    ensure
      RestClient.stubs(:post)
    end
  end
end