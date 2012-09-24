module HTTP
  class Query
    attr_accessor :url, :callback

    def initialize(url_string, &block)
      @callback = block
      request = NSMutableURLRequest.requestWithURL(NSURL.URLWithString(url_string), cachePolicy: NSURLRequestUseProtocolCachePolicy, timeoutInterval: 60.0)
      connection = NSURLConnection.connectionWithRequest(request, delegate: self)
    end

    def connectionDidFinishLoading(connection)
      @callback.call('foo')
    end
  end
end

class Foo
  def bar
    NSLog "Getting request"
    HTTP::Query.new("http://www.google.com") do |response|
      NSLog "Got Response"
    end
  end
end

class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    # Using this does not work; it seems that the response block in Foo#bar
    # isn't being retained properly, so by the time connectionDidFinishLoading
    # calls it, it no longer exists and crashes.
    #
    Foo.new.bar

    # Assigning to a local variable doesn't work either:
    #
    # f = Foo.new
    # f.bar

    # Using an instance variable works, however:
    #
    # @foo = Foo.new
    # @foo.bar

    # Calling HTTP#get directly instead of using a separate class works fine:
    #
    # HTTP.get("http://www.google.com") do |response|
    #   NSLog "Got a response..."
    # end

    true
  end
end
