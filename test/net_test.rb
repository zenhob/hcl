require 'test_helper'

class NetTest < HCl::TestCase

  def test_configure
    assert_equal 'bob', http.login
    assert_equal 'secret', http.password
    assert_equal 'bobclock', http.subdomain
    assert_equal true, http.ssl
  end

  def test_http_deep_unescape
    register_uri(:get, "/foo", {
      status:'gotten &amp; got!',
      comparisons:['burrito &gt; taco', 'rain &lt; sun']
    })
    body = http.get 'foo'
    assert_equal 'gotten & got!', body[:status]
    assert_equal 'burrito > taco', body[:comparisons][0]
    assert_equal 'rain < sun', body[:comparisons][1]
  end

  def test_http_get
    register_uri(:get, "/foo", {message:'gotten!'})
    body = http.get 'foo'
    assert_equal 'gotten!', body[:message]
  end

  def test_http_post
    register_uri(:post, "/foo", {message:'posted!'})
    body = http.post 'foo', {pizza:'taco'}
    assert_equal 'posted!', body[:message]
  end

  def test_http_delete
    register_uri(:delete, "/foo", {message:'wiped!'})
    body = http.delete 'foo'
    assert_equal 'wiped!', body[:message]
  end
end
