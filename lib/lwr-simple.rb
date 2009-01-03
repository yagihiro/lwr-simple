#
# = lwr-simple.rb
#
# LWR::Simple library is yet another LWP::Simple library for ruby.
#
# == FEATURES/PROBLEMS:
#
# See LWR::Simple module's documents.
#
#--
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
#++
#

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require "net/http"
require "time"
require "uri"

module LWR                      # :nodoc:

  # This module extend toplevel.
  # So, in your application, see below example code.
  #
  #   puts get("http://www.google.com/")
  #   mirror("http://www.ruby-lang.org/images/logo.gif", "logo.gif") #=> save "logo.gif" as local file.
  #
  module Simple
    VERSION = '0.0.1'

   module_function

    # This method will fetch the document identified by the given +url+ and return it as String.
    # It returns +nil+ if it fails. The +url+ argument can be either a String's instance.
    #
    # +url+:: request target url as String.
    #
    def get url
      _get(to_uri(url)).body
    rescue
      nil
    end

    # Get document headers.
    # Returns the following 5 values if successful: [+content_type+, +document_length+, +modified_time+, +expires+, +server+].
    # All values in return Array are String or nil.
    # Returns an empty list if this method fails.
    #
    # +url+:: request target url as String.
    #
    def head url
      uri = to_uri url
      req = Net::HTTP::Get.new uri.path
      res = Net::HTTP.start(uri.host, uri.port) {|http| http.request(req) }

      # +modified_time+ value is  provisional it using +Date+ header.
      [res.content_type, res.content_length, res["date"], res["expires"], res["server"]]
    rescue
      []
    end

    # Get and print a document identified by a +url+.
    # The document is printed to $stdout as data is received from the network.
    # If the request fails, then the status code and message are printed on $stderr.
    # The return value is the HTTP response code as Fixnum.
    #
    # +url+:: request target url as String.
    #
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

    # Gets a document identified by a +url+ and stores it in the +file+.
    # The return value is the HTTP response code as Fixnum.
    #
    # +url+:: request target url as String.
    # +file+:: store path as String
    #
    def getstore url, file
      uri = to_uri url
      res = _get uri
      _store file, res.body
      res.code.to_i
    rescue
      res ? res.code.to_i : 404
    end

    # Get and store a document identified by a +url+, using If-modified-since.
    # The return value is the HTTP response code as Fixnum.
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

    ###
    ### below methods are only internal use.
    ###

    def to_uri url              # :nodoc:
      uri = URI.parse url
      uri.path = "/" if uri.path.empty?
      uri
    end

    def _get uri                # :nodoc:
      req = Net::HTTP::Get.new uri.path
      res = Net::HTTP.start(uri.host, uri.port) {|http| http.request(req) }
      res
    end

    def _store path, s          # :nodoc:
      File.open(path, "wb") {|f| f.write(s) }
    end

  end

end

# All LWR::Simple's methods extend to Object class.
extend LWR::Simple
