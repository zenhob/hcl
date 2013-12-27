require 'test_helper'

class NetTest < HCl::TestCase

  def test_configure
    assert_equal 'bob', HCl::Net.login
    assert_equal 'secret', HCl::Net.password
    assert_equal 'bobclock', HCl::Net.subdomain
    assert_equal true, HCl::Net.ssl
  end

  def test_http_deep_unescape
    register_uri(:get, "/foo", {
      status:'gotten &amp; got!',
      comparisons:['burrito &gt; taco', 'rain &lt; sun']
    })
    body = HCl::Net.get 'foo'
    assert_equal 'gotten & got!', body[:status]
    assert_equal 'burrito > taco', body[:comparisons][0]
    assert_equal 'rain < sun', body[:comparisons][1]
  end

  def test_http_get
    register_uri(:get, "/foo", {message:'gotten!'})
    body = HCl::Net.get 'foo'
    assert_equal 'gotten!', body[:message]
  end

  def test_http_post
    register_uri(:post, "/foo", {message:'posted!'})
    body = HCl::Net.post 'foo', {pizza:'taco'}
    assert_equal 'posted!', body[:message]
  end

  def test_http_delete
    register_uri(:delete, "/foo", {message:'wiped!'})
    body = HCl::Net.delete 'foo'
    assert_equal 'wiped!', body[:message]
  end
end
