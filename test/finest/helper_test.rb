require 'minitest/autorun'

class Changelog
  include Finest::Builder
end

class Finest::HelperTest < Minitest::Test
  def setup
    @change_log = {"id" => "5357608",
                   "author" =>
                       {"self" => "http://test.jira.com/rest/api/2/user?username=hocus.pocus",
                        "name" => "hocus.pocus",
                        "key" => "hocus.pocus",
                        "emailAddress" => "hocus.pocus@binky-builder.com",
                        "avatarUrls" => {
                            "_48x48" => "http://test.jira.com/secure/useravatar?ownerId=hocus.pocus&avatarId=12221",
                            "_24x24" => "http://test.jira.com/secure/useravatar?size=small&ownerId=ahocus.pocus&avatarId=12221",
                            "_16x16" => "http://test.jira.com/secure/useravatar?size=xsmall&ownerId=hocus.pocus&avatarId=12221",
                            "_32x32" => "http://test.jira.com/secure/useravatar?size=medium&ownerId=hocus.pocus&avatarId=12221"},
                        "displayName" => "Hocus Pocus",
                        "active" => true,
                        "timeZone" => "Europe/Madrid"
                       },
                   "created" => "2020-03-17T21:00:57.000+0100",
                   "items" => [
                       {"field" => "status", "fieldtype" => "jira", "from" => "10682", "fromString" => "Ready for Production", "to" => "10011", "toString" => "Production"}
                   ]}
  end

  def teardown
    @change_log = nil
  end

  def test_builder_with_real_data
    e = Changelog.new.build_by_keys(@change_log, ["id", "fromString", "toString", "fieldtype", "avatar"])
    assert_equal e.tostring, "Production"
    assert_equal e.fromstring, "Ready for Production"
  end

  def test_builder_without_keys
    e = Changelog.new(@change_log)
    assert_equal e.items[0]["toString"], "Production"
    assert_equal e.items[0]["fromString"], "Ready for Production"
  end
end