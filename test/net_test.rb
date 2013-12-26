require 'test_helper'

class NetTest < HCl::TestCase

  def setup
    FakeWeb.allow_net_connect = false
    HCl::Net.configure \
      'login' => 'bob',
      'password' => 'secret',
      'subdomain' => 'bobclock',
      'ssl' => true
  end

  def test_configure
    assert_equal 'bob', HCl::Net.login
    assert_equal 'secret', HCl::Net.password
    assert_equal 'bobclock', HCl::Net.subdomain
    assert_equal true, HCl::Net.ssl
  end

  def test_http_deep_unescape
    FakeWeb.register_uri(:get, "https://bob:secret@bobclock.harvestapp.com/foo",
                         :body => Yajl::Encoder.encode({
      status:'gotten &amp; got!',
      comparisons:['burrito &gt; taco', 'rain &lt; sun']
    }))
    body = HCl::Net.get 'foo'
    assert_equal 'gotten & got!', body[:status]
    assert_equal 'burrito > taco', body[:comparisons][0]
    assert_equal 'rain < sun', body[:comparisons][1]
  end

  def test_http_get
    FakeWeb.register_uri(:get, "https://bob:secret@bobclock.harvestapp.com/foo",
                         :body => 'gotten!'.inspect)
    body = HCl::Net.get 'foo'
    assert_equal 'gotten!', body
  end

  def test_http_post
    FakeWeb.register_uri(:post, "https://bob:secret@bobclock.harvestapp.com/foo",
                         :body => 'posted!'.inspect)
    body = HCl::Net.post 'foo', {pizza:'taco'}
    assert_equal 'posted!', body
  end

  def test_http_delete
    FakeWeb.register_uri(:delete, "https://bob:secret@bobclock.harvestapp.com/foo",
                         :body => 'wiped!'.inspect)
    body = HCl::Net.delete 'foo'
    assert_equal 'wiped!', body
  end
end
