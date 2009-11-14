require File.dirname(__FILE__) + '/../test_helper'

class UserAccountMailerTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
    @expected.mime_version = '1.0'
  end

  def test_confirm_registration
    @expected.subject = 'UserAccountMailer#confirm_registration'
    @expected.body    = read_fixture('confirm_registration')
    @expected.date    = Time.now

    assert_equal @expected.encoded, UserAccountMailer.create_confirm_registration(@expected.date).encoded
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/user_account_mailer/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
