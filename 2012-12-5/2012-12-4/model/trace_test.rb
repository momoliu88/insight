require "test/unit"
require "trace"
require "receiver"
require "pp"
require "test/unit/ui/console/testrunner"
class TraceTest<Test::Unit::TestCase
  include Receiver
  def setup
    data1='{"trace_group":"HTTP","trace_duration":431463000,"http_request":{"headers":[{"name":"host","value":"10.1.60.102:11116"},{"name":"connection","value":"keep-alive"},{"name":"user-agent","value":"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.94 Safari/537.4"},{"name":"accept","value":"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"},{"name":"accept-encoding","value":"gzip,deflate,sdch"},{"name":"accept-language","value":"zh-CN,zh;q=0.8"},{"name":"accept-charset","value":"GBK,utf-8;q=0.7,*;q=0.3"}],"protocol":"HTTP/1.1","queryParams":[],"localPort":"11116","remotePort":"-1","method":"GET","attributes":[],"servletName":"Unknown","contentLength":"0","uri":"/tomcat.png","remoteAddr":"10.1.93.185"},"frames":[{"id":"93dd05d2-f438-4326-82e9-615a6f6bba09","duration":431463000,"desc":[{"title":"ExtraTraceData","params":{"mandatory":"false"}},{"title":"properties","params":{"statusCode":"200","returnValue":"void","label":"GET /tomcat.png","ExtraTraceData":"","type":"OperationType[http]","contentLength":"5103"}}],"start_time":1352189090074082000,"operation_signature":"GET /tomcat.png"}],"trace_start_time_ns":1352189090074082000,"trace_id":"3575b5a7-12f4-4b01-b991-c92c84fa473c","trace_start_time":1352279068074,"user_id":"test@ebupt.com","pid":29220,"http_response":{"statusCode":"200","headers":[{"name":"Accept-Ranges","value":"bytes"},{"name":"ETag","value":"W/\"5103-1341286428000\""},{"name":"Last-Modified","value":"Tue, 03 Jul 2012 03:33:48 GMT"},{"name":"Content-Type","value":"image/png"},{"name":"Content-Length","value":"5103"},{"name":"Date","value":"Tue, 06 Nov 2012 08:04:50 GMT"}],"body":"","reasonPhrase":"200","contentLength":"5103"},"target_application":"GET /tomcat.png","endpoint":"GET /tomcat.png"}'
    data2='{"trace_group":"HTTP","trace_duration":101832800,"http_request":{"headers":[{"name":"user-agent","value":"curl/7.15.5 (x86_64-redhat-linux-gnu) libcurl/7.15.5 OpenSSL/0.9.8b zlib/1.2.3 libidn/0.6.5"},{"name":"host","value":"127.0.0.1:11116"},{"name":"accept","value":"*/*"}],"protocol":"HTTP/1.1","queryParams":[],"localPort":"11116","remotePort":"-1","method":"GET","attributes":[],"servletName":"Unknown","contentLength":"0","uri":"/tomcat.png","remoteAddr":"127.0.0.1"},"frames":[{"id":"2bc5c98f-b75d-4af9-a7c7-caf3deb1e702","duration":101832000,"desc":[{"title":"ExtraTraceData","params":{"mandatory":"false"}},{"title":"properties","params":{"statusCode":"200","returnValue":"void","label":"GET /tomcat.png","ExtraTraceData":"","type":"OperationType[http]","contentLength":"5103"}}],"start_time":1352259130452035000,"operation_signature":"GET /tomcat.png"}],"trace_start_time_ns":1352259130482035000,"trace_id":"3d76ed23-cde0-4108-b8bb-37744e7463e5","trace_start_time":1352261100582,"user_id":"test@ebupt.com","pid":29220,"http_response":{"statusCode":"200","headers":[{"name":"Accept-Ranges","value":"bytes"},{"name":"ETag","value":"W/\"5103-1341286428000\""},{"name":"Last-Modified","value":"Tue, 03 Jul 2012 03:33:48 GMT"},{"name":"Content-Type","value":"image/png"},{"name":"Content-Length","value":"5103"},{"name":"Date","value":"Wed, 07 Nov 2012 03:32:10 GMT"}],"body":"","reasonPhrase":"200","contentLength":"5103"},"target_application":"GET /tomcat.png","endpoint":"GET /tomcat.png"}'
    receive [data1,data2]
    @trace=Trace.new data1
  end
  def teardown
    Trace.clear()
  end
  def test_isHttp?
    assert_equal(true,@trace.isHttp?,"trace is not http"); 
  end
  def test_expires?
    assert_equal(true,@trace.expires?,"expires.");
  end
  def test_get_all_traceids_by_userid
    Trace.get_all_traceids_by_userid "test@ebupt.com"
  end
  def  test_dispatch
    pp @trace.dispatch "test@ebupt.com"
    pp (Trace.get_traces_by_user "test@ebupt.com").length
  end
  def test_filename
    assert_equal("./test@ebupt.com/2012-11-06/3575b5a7-12f4-4b01-b991-c92c84fa473c",@trace.filename);
  end  
  def test_max_duration
    traces = Trace.get_traces_by_user "test@ebupt.com"
    p @trace.max_duration traces
  end
  def test_persist
    @trace.persist
  end
  def test_get_trace_from_file 
    pp Trace.get_trace_from_file "./test@ebupt.com/2012-11-06/3575b5a7-12f4-4b01-b991-c92c84fa473c"

  end
end
class DataProcessorTest < Test::Unit::TestCase
  include DataProcessor
  def test_search_trace 
     search_trace "png","test@ebupt.com","abc"
  end
  def test_search_traces
     search_traces "/home/liuxiaoqin/server in rb/model/test@ebupt.com","get"
  end 
  def test_groupby
    group_by "statusCode","/home/liuxiaoqin/server in rb/model/test@ebupt.com"
  end
  def test_format
    data=[{"name"=> "Accept-Ranges","value"=> "bytes"},{"name"=> "ETag","value"=>"W/\"5103-1341286428000\""},{"name"=> "Last-Modified","value"=> "Tue, 03 Jul 2012 03:33:48 GMT"},{"name"=> "Content-Type","value"=> "image/png"},{"name"=> "Content-Length","value"=> "5103"},{"name"=> "Date","value"=> "Thu, 01 Nov 2012 10:23:03 GMT"}]
    expected={"Accept-Ranges"=>"bytes","ETag"=>"W/\"5103-1341286428000\"","Last-Modified"=>"Tue, 03 Jul 2012 03:33:48 GMT","Content-Type"=>"image/png","Content-Length"=>"5103","Date"=>"Thu, 01 Nov 2012 10:23:03 GMT"}
    data=format(data)
    assert_equal(expected,data);
  end
end 
Test::Unit::UI::Console::TestRunner.run(TraceTest)
Test::Unit::UI::Console::TestRunner.run(DataProcessorTest)
