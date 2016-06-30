require 'json'
require 'redic'
require 'securerandom'

module Philote
  def self.redis
    @redis ||= Redic.new
  end

  def self.redis=(client)
    @redis = client
  end

  def self.prefix
    @prefix ||= 'philote'
  end

  def self.prefix=(p)
    @prefix = p
  end

  def self.publish(channel, data)
    redis.call('PUBLISH', "philote:channel:#{channel}", data)
  end

  class AccessKey
    attr_accessor :read, :write, :allowed_uses, :uses, :token


    # read:
    #   an array of channel names the key user will be subscribed to.
    #
    # write:
    #   an array of channel names the key user will be able to write to.
    #
    # allowed_uses:
    #   the ammount of times a new websocket client will be able to authenticate
    #   using this access key.
    #
    # uses:
    #   the ammount of times a new websocket client has authenticated using this
    #   access key.
    #
    # token:
    #   the redis identifier.
    #
    def initialize(read: [], write: [], allowed_uses: 1, uses: 0, token: nil)
      @token = token || SecureRandom.urlsafe_base64
      @read = read
      @write = write
      @allowed_uses = allowed_uses
      @uses = uses

      self
    end

    def to_json
      self.to_h.to_json
    end

    def save
      Philote.redis.call('SET', "#{ Philote.prefix }:access_key:#{ token }", self.to_json)
    end

    def to_h
      {
        read: read,
        write: write,
        allowed_uses: allowed_uses,
        uses: uses
      }
    end
    alias_method :to_hash, :to_h


    def self.create(**args)
      key = self.new(**args)
      key.save

      return key
    end

    def self.load!(token)
      raw_key = Philote.redis.call('GET', "philote:access_key:#{ token }")
      raise NonExistantAccessKey if raw_key.nil?

      begin
        parsed_key_attributes = JSON.parse(raw_key)
      rescue => exception
        raise UnparsableAccessKeyData.new(exception)
      end

      begin
        key_attributes = {
          read: parsed_key_attributes.fetch('read'),
          write: parsed_key_attributes.fetch('write'),
          allowed_uses: parsed_key_attributes.fetch('allowed_uses'),
          uses: parsed_key_attributes.fetch('uses'),
          token: token
        }
      rescue => exception
        raise InsufficientAccessKeyData.new(exception)
      end

      return self.new(key_attributes)
    end

    def self.load(token)
      begin
        key = self.load!(token)
        return key
      rescue => exception
        return nil
      end
    end
  end

  class Error < StandardError; end
  class NonExistantAccessKey < Error; end
  class UnparsableAccessKeyData < Error; end
  class InsufficientAccessKeyData < Error; end
end

require_relative 'philote/version'
