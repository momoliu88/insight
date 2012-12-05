require 'model/trace_array'
require 'model/trace'
require 'pp'
class TraceCache
  attr_accessor :expires,:active_traces_in_file
  attr_reader :maxsize,:traces
  #expire:seconds
  def initialize(maxsize,expire)
    @traces = {}
    @expires = expire
    @maxsize = maxsize
    @active_traces_in_file={}
  end
  def [](key)
    @traces[key]
  end
  alias :get :[]
  def add(key,value)
    @traces[key] = TraceArray.new unless @traces.has_key? key    
    size = @traces[key].size
    if(size >= @maxsize)
      size = clean_expire @traces[key]
    end
    
    if (!expires? value.start_time)
      if size >= @maxsize
        @active_traces_in_file[key]= Hash.new unless @active_traces_in_file.has_key? key
        @active_traces_in_file[key].delete_if{|k,v| expires? k }
        while size >= @maxsize
          trace = @traces[key].shift
          @active_traces_in_file[key][trace.start_time]=Array.new unless @active_traces_in_file[key][trace.start_time]
          @active_traces_in_file[key][trace.start_time] << trace.traceid
          size -=1 
        end
      end
      @traces[key] << value
    end
  end
  def expires? time
    time+@expires*1000 <= Time.now.to_f*1000
  end
  def clean_expire traces
     counter = 0
     traces.each_index{|i|
       trace = traces[i]
       break unless expires? trace.start_time
       counter+=1
     }
    p "counter #{counter}"
     (0...counter).each{|i|
       traces.shift
     }
    traces.size
  end 
end
if __FILE__ == $0
  data='{"trace_group":"HTTP","trace_duration":101832800,"http_request":{"headers":[{"name":"user-agent","value":"curl/7.15.5 (x86_64-redhat-linux-gnu) libcurl/7.15.5 OpenSSL/0.9.8b zlib/1.2.3 libidn/0.6.5"},{"name":"host","value":"127.0.0.1:11116"},{"name":"accept","value":"*/*"}],"protocol":"HTTP/1.1","queryParams":[],"localPort":"11116","remotePort":"-1","method":"GET","attributes":[],"servletName":"Unknown","contentLength":"0","uri":"/tomcat.png","remoteAddr":"127.0.0.1"},"frames":[{"id":"2bc5c98f-b75d-4af9-a7c7-caf3deb1e702","duration":101832000,"desc":[{"title":"ExtraTraceData","params":{"mandatory":"false"}},{"title":"properties","params":{"statusCode":"200","returnValue":"void","label":"GET /tomcat.png","ExtraTraceData":"","type":"OperationType[http]","contentLength":"5103"}}],"start_time":1352259130452035000,"operation_signature":"GET /tomcat.png"}],"trace_start_time_ns":1352259130482035000,"trace_id":"0","trace_start_time":1352261100582,"user_id":"test@ebupt.com","pid":29220,"http_response":{"statusCode":"200","headers":[{"name":"Accept-Ranges","value":"bytes"},{"name":"ETag","value":"W/\"5103-1341286428000\""},{"name":"Last-Modified","value":"Tue, 03 Jul 2012 03:33:48 GMT"},{"name":"Content-Type","value":"image/png"},{"name":"Content-Length","value":"5103"},{"name":"Date","value":"Wed, 07 Nov 2012 03:32:10 GMT"}],"body":"","reasonPhrase":"200","contentLength":"5103"},"target_application":"GET /tomcat.png","endpoint":"GET /tomcat.png"}'
  trace = Trace.new(data) 
  trace1 = Trace.new(data)
  trace1.start_time = Time.now.to_i*1000
  trace1.traceid = 1
  trace2 = Trace.new(data)
  trace2.traceid = 2
  trace2.start_time = (Time.now.to_i-14*60)*1000
  cache = TraceCache.new(1,15*60) 
  p "trace1"
  cache.add("abc",trace1)
  p "trace"
  cache.add("abc",trace)
  p "trace2"
  cache.add("abc",trace2)

  cache["abc"].each{|item|
    p "traceid #{item.traceid} starttime: #{item.start_time}"
  }
  pp cache.active_traces_in_file
end
