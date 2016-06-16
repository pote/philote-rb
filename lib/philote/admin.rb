module Philote::Admin
  def self.create_token(read: [], write: [], allowed_uses: 1)
    permissions = {
      read: read,
      write: write,
      allowed_uses: allowed_uses,
      uses: 0
    }

    token = SecureRandom.urlsafe_base64

    Philote.redis.call('SET', "philote:access_key:#{token}", permissions.to_json )
  end

  def self.publish(channel, message)
    Philote.redis.call('PUBLISH', channel, message )
  end
end
