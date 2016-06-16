require 'json'
require 'redic'
require 'securerandom'

module Philote
  def self.redis
    @redis ||= Redic.new
  end

  def self.redis=(redis)
    @redis = redis
  end
end

require_relative 'philote/version'
require_relative 'philote/admin'
