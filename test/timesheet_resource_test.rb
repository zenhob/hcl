require 'test_helper'

class TimesheetResourceTest < HCl::TestCase

  def setup
    FakeWeb.allow_net_connect = false
    HCl::TimesheetResource.configure \
      'login' => 'bob',
      'password' => 'secret',
      'subdomain' => 'bobclock',
      'ssl' => true
  end

  def test_configure
    assert_equal 'bob', HCl::TimesheetResource.login
    assert_equal 'secret', HCl::TimesheetResource.password
    assert_equal 'bobclock', HCl::TimesheetResource.subdomain
    assert_equal true, HCl::TimesheetResource.ssl
  end

  def test_http_get
    FakeWeb.register_uri(:get, "https://bob:secret@bobclock.harvestapp.com/foo",
                         :body => 'gotten!'.inspect)
    body = HCl::TimesheetResource.get 'foo'
    assert_equal 'gotten!', body
  end

  def test_http_post
    FakeWeb.register_uri(:post, "https://bob:secret@bobclock.harvestapp.com/foo",
                         :body => 'posted!'.inspect)
    body = HCl::TimesheetResource.post 'foo', {pizza:'taco'}
    assert_equal 'posted!', body
  end

  def test_http_delete
    FakeWeb.register_uri(:delete, "https://bob:secret@bobclock.harvestapp.com/foo",
                         :body => 'wiped!'.inspect)
    body = HCl::TimesheetResource.delete 'foo'
    assert_equal 'wiped!', body
  end
end
