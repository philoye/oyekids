# = Icebox : Caching for HTTParty
#
# First stab at implementing caching for HTTParty (http://github.com/jnunemaker/httparty/)
# Modeled after Martyn Loughran's APICache (http://github.com/newbamboo/api_cache/)
#
# = Usage
# 1. <tt>include Icebox</tt> in YourPartyAnimalClass
# 2. Use <tt>YourPartyAnimalClass.get_cached()</tt> instead of simple <tt>get()</tt>

require 'logger'
require 'ftools'
require 'pathname'
require 'digest/md5'

module Icebox

  ::LOGGER = Logger.new(STDOUT) unless defined?(::LOGGER)

  def self.included(receiver)
    receiver.extend ClassMethods
  end

  module ClassMethods

    @cache = nil

    # Cache object accessor
    # == Arguments
    # [store]       Storage mechanism for cached data (memory, filesystem, your own)
    # [timeout]     Cache expiration in seconds
    def cache(options={})
      options[:store]   ||= 'memory'
      options[:timeout] ||= 900
      @@cache ||= Cache.new( const_get("#{options.delete(:store).capitalize}Store").new(options) )
    end

    # Get cached API response, fresh from the ice-box, if it exists, and is still fresh.
    # Otherwise, load from network and cache the response body
    # FIXME : Return from cache if response.code == 304
    # FIXME : Cache ONLY IF response.code == 200
    # FIXME : Response headers are lost when cached
    def get_cached(path, options={})
      if cache.exists?(path) and not cache.stale?(path)
        LOGGER.debug "Getting data from cache"
        value = cache.get(path)
        return HTTParty::Response.new(value, value, 200, {})
      else
        LOGGER.debug "Getting data from network"
        value = get(path, options)
        cache.set(path, value)
        # FIXME : Getting a String here no matter what we do...
        # value = HTTParty::Request.new(Net::HTTP::Get, base_uri + path, options).perform
        # puts value.class
        # cache.set(path, value) if value.respond_to?(:code) && value.code == 200
        return value
      end
    end
    
  end

  # Basic caching implementation, modeled after APICache
  class Cache

    attr_accessor :store
    def initialize(store)
      @store = store
    end

    def get(key)
      @store.get( encode(key) )
    end

    def set(key, value)
      @store.set( encode(key), value )
    end

    def exists?(key)
      @store.exists?( encode(key) )
    end

    def stale?(key)
      @store.stale?( encode(key) )
    end

    private

    def encode(key)
      Digest::MD5.hexdigest( key )
    end
    
  end

  # Store cached values in memory
  class MemoryStore
    def initialize(options={})
      LOGGER.info "Using memory store"
      @timeout = options[:timeout] || 4 # Sec
      @store = {}
      true
    end
    def set(key, value)
      LOGGER.info("Cache: set (#{key})")
      @store[key] = [Time.now, value]
      true
    end
    def get(key)
      data = @store[key][1] rescue nil
      LOGGER.info("Cache: #{data.nil? ? "miss" : "hit"} (#{key})")
      return data
    end
    def exists?(key)
      !@store[key].nil?
    end
    def stale?(key)
      return true unless exists?(key)
      Time.now - created(key) > @timeout
    end
    private
    def created(key)
      @store[key][0]
    end
  end

  # Store cached values on filesystem
  class FileStore
    def initialize(options={})
      @timeout = options[:timeout] || 4 # Sec
      options[:path] ||= File.join( File.dirname(__FILE__), 'tmp', 'cache' )
      @path    = Pathname.new( options[:path] )
      FileUtils.mkdir_p( @path )
      LOGGER.info "Using file store in '#{@path}'"
      true
    end
    def set(key, value)
      LOGGER.info("Cache: set (#{key})")
      File.open( @path.join(key), 'w' ) { |file| file << value }
      true
    end
    def get(key)
      data = File.read( @path.join(key) ) rescue nil
      LOGGER.info("Cache: #{data.nil? ? "miss" : "hit"} (#{key})")
      return data
    end
    def exists?(key)
      File.exists?( @path.join(key) )
    end
    def stale?(key)
      return true unless exists?(key)
      Time.now - created(key) > @timeout
    end
    private
    def created(key)
      File.mtime( @path.join(key) )
    end
  end

end

# Major parts of this code are based on architecture of ApiCache 
# http://github.com/newbamboo/api_cache/tree/master
# 
# Copyright (c) 2008 Martyn Loughran
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
