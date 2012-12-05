require 'model/preprocessor'
require 'model/trace'
require 'model/log'
require 'pp'
require 'model/trace_cache'
module Receiver
  include Preprocessor

  def receive datas
    datas.each do|data|
	  if validate_json?data
	    store data
	  else
		Log.log.warn("#{data} is not a valid json")
	  end
    end
  end
  def store data
	p "store data"
    trace = Trace.new(data)
    user = trace.userid
    trace.persist
  	Trace.cache.add(user,trace)
    users=Trace.cache.traces.keys.join(";")	
  end
end

if __FILE__ == $0 
  datas = ['{"trace_group":"LIFECYLE","trace_duration":1069950,"frames":[{"id":"efea29c7-259c-4a1a-9bf6-e99b382681d8","duration":1069950,"desc":[{"title":"ExtraTraceData","params":{"mandatory":"false"}},{"title":"properties","params":{"statusCode":"200","returnValue":"void","label":"POST /monitor-task-schedule/task","ExtraTraceData":"","type":"OperationType[http]","contentLength":"0"}}],"frames":[{"id":"3c566a5d-dd07-41ad-95c9-99951fcd2e7e","duration":593011,"desc":[{"title":"response","params":{"headers":"","statusCode":"200","contentSize":"-1","reasonPhrase":"200"}},{"title":"request","params":{"headers":"{name=host, value=localhost},{name=content-type, value=text/plain;charset=utf8},{name=content-length, value=101}","protocol":"HTTP/1.1","queryParams":"","userPrincipal":"","locale":"zh_CN","servletName":"task","uri":"/monitor-task-schedule/task","contextAvailable":"true","queryString":"","sessionId":"","localPort":"10002","contextPath":"/monitor-task-schedule","method":"POST","remotePort":"37843","localAddr":"10.1.70.149","contentLength":"101","remoteAddr":"10.1.70.149"}},{"title":"properties","params":{"response":"","request":"","label":"POST /monitor-task-schedule/task","type":"OperationType[http]"}}],"start_time":1351132870265164264,"operation_signature":"POST /monitor-task-schedule/task"}],"start_time":1351132870265015085,"operation_signature":"POST /monitor-task-schedule/task"}],"trace_start_time_ns":1351132870265015085,"trace_id":"aba6d599-9cb4-4f96-bd22-e671459bd344","trace_start_time":1351132870265,"user_id":"test@ebupt.com","pid":4590,"target_application":"POST /monitor-task-schedule/task","endpoint":"POST /monitor-task-schedule/task"}']
  include Receiver
  receive datas
  pp Trace.traces
end

