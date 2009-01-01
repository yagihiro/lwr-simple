#
# = lwr-simple.rb
#
# LWR::Simple library is yet another LWP::Simple library for ruby.
#
# == SYNOPSIS:
#
# It is an interface that assumes the scene to which LWR::Simple is taken an active part by the one liner like begin so LWP::Simple, too.
# Its interface really looks like the LWP::Simple.
#
# # example. 1
# $ ruby -rlwr-simple -e 'getprint "http://www.sn.no"'
#
# # example. 2
# $ ruby -rlwr-simple -e 'get("http://www.ruby-lang.org/ja/").scan(/<a.*href="(.+?)"/) {|refs| puts(refs[0])}'
#
# == FEATURES/PROBLEMS:
#
# See LWR::Simple module's documents.
#
# == LICENSE:
#
# Copyright (c) 2008 Hiroki Yagita
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# 'Software'), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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

   module_function

    # Fetch a resource by the given +url+, and return the resource as String.
    def get url
      _get(to_uri(url)).body
    rescue
      nil
    end

    # Get document headers - [+content_type+, +document_length+, +modified_time+, +expires+, +server+]
    def head url
      uri = to_uri url
      req = Net::HTTP::Get.new uri.path
      res = Net::HTTP.start(uri.host, uri.port) {|http| http.request(req) }

      # +modified_time+ value is  provisional it using +Date+ header.
      [res.content_type, res.content_length, res["date"], res["expires"], res["server"]]
    rescue
      []
    end

    # Fetch and print a resource by the given +url+.
    def getprint url
      uri = to_uri url
      res = _get uri
      puts res.body
      res.code.to_i
    rescue
      code = 404
      unless res
        $stderr.puts "#{url} is bad URL."
      else
        code = res.code.to_i
        $stderr.puts "#{url} is bad URL(#{code})."
      end
      code
    end

    # Fetch a resource by the given +url+ and save to +file+.
    def getstore url, file
      uri = to_uri url
      res = _get uri
      _store file, res.body
      res.code.to_i
    rescue
      res ? res.code.to_i : 404
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
    rescue
      res ? res.code.to_i : 404
    end

    # only internal use.
    def to_uri url
      uri = URI.parse url
      uri.path = "/" if uri.path.empty?
      uri
    end

    # only internal use.
    def _get uri
      req = Net::HTTP::Get.new uri.path
      res = Net::HTTP.start(uri.host, uri.port) {|http| http.request(req) }
      res
    end

    # only internal use.
    def _store path, s
      File.open(path, "wb") {|f| f.write(s) }
    end

  end

end

# All LWR::Simple's methods extend to Object class.
extend LWR::Simple
