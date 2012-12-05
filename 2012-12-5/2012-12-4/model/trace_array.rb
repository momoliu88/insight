require 'model/sortedarray'
require 'model/trace'
class TraceArray < SortedArray
  def initialize
	  super{|x,y| x.start_time <=> y.start_time}
  end
end
if __FILE__==$0
  array = TraceArray.new 
  data='{"trace_group":"HTTP","trace_duration":101832800,"http_request":{"headers":[{"name":"user-agent","value":"curl/7.15.5 (x86_64-redhat-linux-gnu) libcurl/7.15.5 OpenSSL/0.9.8b zlib/1.2.3 libidn/0.6.5"},{"name":"host","value":"127.0.0.1:11116"},{"name":"accept","value":"*/*"}],"protocol":"HTTP/1.1","queryParams":[],"localPort":"11116","remotePort":"-1","method":"GET","attributes":[],"servletName":"Unknown","contentLength":"0","uri":"/tomcat.png","remoteAddr":"127.0.0.1"},"frames":[{"id":"2bc5c98f-b75d-4af9-a7c7-caf3deb1e702","duration":101832000,"desc":[{"title":"ExtraTraceData","params":{"mandatory":"false"}},{"title":"properties","params":{"statusCode":"200","returnValue":"void","label":"GET /tomcat.png","ExtraTraceData":"","type":"OperationType[http]","contentLength":"5103"}}],"start_time":1352259130452035000,"operation_signature":"GET /tomcat.png"}],"trace_start_time_ns":1352259130482035000,"trace_id":"3d76ed23-cde0-4108-b8bb-37744e7463e5","trace_start_time":1352261100582,"user_id":"test@ebupt.com","pid":29220,"http_response":{"statusCode":"200","headers":[{"name":"Accept-Ranges","value":"bytes"},{"name":"ETag","value":"W/\"5103-1341286428000\""},{"name":"Last-Modified","value":"Tue, 03 Jul 2012 03:33:48 GMT"},{"name":"Content-Type","value":"image/png"},{"name":"Content-Length","value":"5103"},{"name":"Date","value":"Wed, 07 Nov 2012 03:32:10 GMT"}],"body":"","reasonPhrase":"200","contentLength":"5103"},"target_application":"GET /tomcat.png","endpoint":"GET /tomcat.png"}'
  trace = Trace.new(data)
  trace1 = Trace.new(data)
  trace1.start_time = Time.now.to_i*1000
  array << trace1
  array << trace
  array.each {|item| p item.start_time}
end
