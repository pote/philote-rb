require 'cutest'
require 'philote'


setup {
  Philote.redis = Redic.new(ENV.fetch('REDIS_TEST_URL'))
}

at_exit {
  Redic.new(ENV.fetch('REDIS_TEST_URL')).call('FLUSHDB')
}

test 'client should have a functioning redis connection' do
  assert_equal 'PONG', Philote.redis.call('PING')
end

test 'creating an access key creates a token with sensible defaults' do
  access_key = Philote::AccessKey.create

  assert_equal [], access_key.read
  assert_equal [], access_key.write
  assert_equal 1, access_key.allowed_uses
  assert_equal 0, access_key.uses
  assert !access_key.token.nil?
end

test 'loading an access key works' do
  access_key = Philote::AccessKey.create(
    read: %w(mychannel), write: %w(mychannel), allowed_uses: 5, uses: 3)

  assert_equal %w(mychannel), access_key.read
  assert_equal %w(mychannel), access_key.write
  assert_equal 5, access_key.allowed_uses
  assert_equal 3, access_key.uses

  access_key = Philote::AccessKey.load(access_key.token)

  assert !access_key.nil?
  assert access_key.is_a?(Philote::AccessKey)
  assert_equal %w(mychannel), access_key.read
  assert_equal %w(mychannel), access_key.write
  assert_equal 5, access_key.allowed_uses
  assert_equal 3, access_key.uses
  assert !access_key.token.nil?
end
