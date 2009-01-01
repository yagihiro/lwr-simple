require File.dirname(__FILE__) + '/spec_helper.rb'

def successed? code
  200 <= code and code < 400
end

# This spec quotes from the LWP::Simple documents.
describe LWR::Simple do

  describe "get()" do
    it "should be going to fetch the document identified by the given URL and return it." do
      doc = LWR::Simple.get("http://www.google.com/")
      doc.should_not be_nil
      doc.should_not be_empty
      doc.should be_an_instance_of(String)
      doc.should match(/google/)
    end
    it "should nil if this method fails." do
      LWR::Simple.get("http://www.notexists.com/").should be_nil
    end
    it "should URL argument can be either a String's instance." do
      LWR::Simple.get(nil).should be_nil
      LWR::Simple.get(URI("http://www.google.com/")).should be_nil
    end
  end

  describe "head()" do
    it "should get document headers. Returns the following 5 values if successful: ($content_type, $document_length, $modified_time, $expires, $server)" do
      h = LWR::Simple.head("http://www.google.com/")
      h.should_not be_nil
      h.should_not be_empty
      h.should be_an_instance_of(Array)
      h.should have(5).items
    end
    it "should returns an empty list if this method fails." do
      LWR::Simple.head("http://www.notexists.com/").should have(0).items
    end
  end

  describe "getprint()" do
    before do
      @stdout = $>
      @stderr = $stderr
    end
    after do
      $> = @stdout
      $stderr = @stderr
    end
    it "should get and print a document identified by a URL. The document is printed to the selected default filehandle for output (normally STDOUT) as data is received from the network." do
      m = mock("out")
      m.should_receive(:write) do |arg|
        # +arg+ is printed a document as String instance.
        arg.should be_an_instance_of(String)
        arg.should_not be_empty
      end
      $> = m
      code = LWR::Simple.getprint("http://www.google.com/")
      successed?(code).should be_true
    end
    it "should if the request fails, then the status code and message are printed on STDERR. The return value is the HTTP response code." do
      m = mock("err")
      m.should_receive(:write).any_number_of_times # $stderr object requires #write method. (In fact, it is not called.)
      m.should_receive(:puts) do |arg|
        # +arg+ is printed a document as String instance.
        arg.should be_an_instance_of(String)
        arg.should_not be_empty
      end
      $stderr = m
      LWR::Simple.getprint("http://www.notexists.com/").should == 404
    end
  end

  describe "getstore()" do
    after do
      File.delete("g.html") if FileTest.exist?("g.html")
    end
    it "should gets a document identified by a URL and stores it in the file. The return value is the HTTP response code." do
      code = LWR::Simple.getstore("http://www.google.com/", "g.html")
      File.open("g.html") {|f| f.read.should match(/google/) }
      successed?(code).should be_true
    end
  end

  describe "mirror()" do
    after do
      File.delete("logo.gif") if FileTest.exist?("logo.gif")
    end
    it "should get and store a document identified by a URL, using If-modified-since, and checking the Content-Length. Returns the HTTP response code." do
      code = LWR::Simple.mirror("http://www.ruby-lang.org/images/logo.gif", "logo.gif")
      FileTest.exist?("logo.gif").should be_true
      successed?(code).should be_true
      code = LWR::Simple.mirror("http://www.ruby-lang.org/images/logo.gif", "logo.gif")
      FileTest.exist?("logo.gif").should be_true
      successed?(code).should be_true
    end
  end

end
