#
# = lwr-simple.rb
#
# Copyright(c) 2008 Hiroki Yagita
#
# == What is this library?
#
# This library is the powerful web access library like LWP::Simple module.
# All methods are similar interface of LWP::Simple.
#
# == Example
#
# nodoc...
#

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require "net/http"
require "time"
require "uri"

module LWR                      # :nodoc:

  # This module is extend toplevel.
  # So, in your application, see below example code.
  #
  #   puts get("http://www.google.com/")
  #   mirror("http://www.ruby-lang.org/images/logo.gif", "logo.gif") #=> save "logo.gif" as local file.
  #
  module Simple
    VERSION = '0.0.1'

    # Fetch a resource by the given +url+, and return the resource as String.
    def get url
      _get(to_uri(url)).body
    end

    # Get document headers - [+content_type+, +document_length+, +modified_time+, +expires+, +server+]
    def head url
      uri = to_uri url
      req = Net::HTTP::Get.new uri.path
      res = Net::HTTP.start(uri.host, uri.port) {|http| http.request(req) }

      # +modified_time+ value is  provisional it using +Date+ header.
      [res.content_type, res.content_length, res["date"], res["expires"], res["server"]]
    end

    # Fetch and print a resource by the given +url+.
    def getprint url
      uri = to_uri url
      res = _get uri
      puts res.body
      res.code
    end

    # Fetch a resource by the given +url+ and save to +file+.
    def getstore url, file
      uri = to_uri url
      res = _get uri
      _store file, res.body
      res.code
    end

    # Mirror a local file and a remote file method.
    #
    # +url+:: request target url as String.
    # +file+:: mirroring file path as String.
    #
    # return value is http responce code.
    def mirror url, file
      uri = to_uri url
      req = Net::HTTP::Get.new uri.path
      req["If-Modified-Since"] = FileTest.exist?(file) ? File.mtime(file).httpdate : Time.at(0).httpdate
      res = Net::HTTP.start(uri.host, uri.port) {|http| http.request(req) }

      # if +code+ is +http not modified+, fetch the url resource.
      code = res.code.to_i
      _store(file, _get(uri).body) unless code == 304

      code
    end

    private
    def to_uri url
      uri = URI.parse url
      uri.path = "/" if uri.path.empty?
      uri
    end

    def _get uri
      req = Net::HTTP::Get.new uri.path
      res = Net::HTTP.start(uri.host, uri.port) {|http| http.request(req) }
      res
    end

    def _store path, s
      File.open(path, "wb") {|f| f.write(s) }
    end

  end

end

# All LWR::Simple's methods extend to Object class.
extend LWR::Simple
