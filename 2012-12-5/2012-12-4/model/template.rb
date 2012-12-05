module Template
  #echo like 
  #<h3>Longest running Traces:2012-10-25 17:38:22 - 17:38:37<\/h3>
  #<hr />
  #<table><tr><td class='right'>1.872412 ms<\/td><td>GET /data-service/get-monitor-item-update<\/td><\/tr>
  #       <tr><td class='right'>1.78176 ms<\/td><td>dealtask.DeliverTask#run()<\/td><\/tr>
  #<\/table>
  #traces is Array
  def template_tooltip traces,_start,_end
    heads="Longest running Traces:"+Time.at(_start/1000.0).strftime("%Y-%m-%d %H:%M:%S")+" - "+Time.at(_end/1000.0).strftime("%H:%M:%S")
    if traces.length==0 then 
      bodys=""
    elsif traces.length==1 then 
        traces_for_table= traces
        bodys=template_format(traces_for_table[0])
    else 
        traces_for_table= traces.sort_by{rand}.slice(0,2)
        bodys=template_format(traces_for_table[0])+template_format(traces_for_table[1])
    end
    message_all="<h3>#{heads}<\/h3><hr \/><table>#{bodys}<\/table>"
  end

  def template_format trace
    duration_ms=trace.duration/1000000.0
    endpoint   =trace.endpoint
    trs="<tr><td class='right'>#{duration_ms} ms<\/td><td>#{endpoint}<\/td><\/tr>"
  end
  
=begin
  "id": "3dbd5b33-3453-4c45-a443-5e125d77ef97",
  "duration": "32422092000",
  "start_time": "1353377496584029000",
  "operation_signature": "Servlet Context: /CompleteTomcat Initialized",
  "start_time_str": "10:11:36 ( 32422 ms )",
  "frames": []
=end
  def template_all_traces traceids
	return unless traceids
	results = Array.new
	counter = 1
	id_map = Hash[traceids.sort]
    id_map.each{|k,v|
	  map = Hash.new
	  map["id"] = counter
	  counter +=1
	  map["signature"] = k
	  map["traces"] = Array.new
	  sorted_v=v.sort{|x,y| y["matched"]-x["matched"]}
	  sorted_v.each{|item|
	    inner_map = Hash.new
		inner_map["signature"] = item["traceid"]+":"+item["endpoint"]
		inner_map["traceid"] = item["traceid"]
		inner_map["id"] = counter
		counter +=1
		map["traces"] << inner_map
	  }
	  results << map
	}
	results
  end
  def template_groupby traces,keyword,searchkeyword
    result = Array.new
	counter = 1
    traces.each{|map|
	  _map = Hash.new
	  _traces = map["traces"].sort{|x,y|y["matched"]-x["matched"]}
	  _map["id"]=counter
	  counter +=1
	  _map["signature"] = keyword+":"+map[keyword]
	  _map["traces"] = Array.new
	  _traces.each{|item|
	    _inner = Hash.new
		_inner["id"]= counter
		_inner["traceid"]=item["id"]
		counter +=1
		if searchkeyword
			_inner["signature"] = item["id"]+":"+item["endpoint"].gsub(/(#{searchkeyword})/i,'<font style="BACKGROUND-COLOR:yellow">\1</font>') 
		else
			_inner["signature"] = item["id"]+":"+item["endpoint"]
		end
		_map["traces"] << _inner
	  }
	  result << _map
	}
	result
  end
  def templater_trace trace,isSearch,keyword,isInTime
	tracdetail={} unless tracdetail
	results = nil
	results = trace.search keyword if isSearch
	tracdetail["id"]=trace.traceid
	tracdetail["duration"]=trace.duration
	tracdetail["start_time"]=trace.start_time_ns
	tracdetail["operation_signature"]=trace.endpoint
	stime =(trace.start_time/1000.0)
	stime=Time.at(stime).strftime("%H:%M:%S")
	dutions=tracdetail["duration"]/1000000.0
	tracdetail["start_time_str"]="#{stime} ( #{dutions} ms)"
	if trace.http_response && trace.http_request && !isInTime
	  tracdetail["http_response"] = trace.http_response 
	  tracdetail["http_response"]["body_encode"]=trace.body_type
	  tracdetail["http_response"]["body"] = trace.read_body
	  tracdetail["http_request"] = trace.http_request 
	end
	tracdetail["frames"]=handle_sub_frames trace.frames,isSearch,results,keyword
	tracdetail["expanded"]=1
    [tracdetail]
  end 
  
=begin
  "id": "50321de8-6b2a-4a3a-8e1a-7bb3c6f17a57",
  "duration": 32422092000,
  "start_time": 1353377496584029000,
  "operation_signature": "Servlet Context: /CompleteTomcat Initialized",
  "desc": "<h2>contextParams</h2><table class=\"dl\"><tbody></tbody></table>
           <h2>ExtraTraceData</h2><table class=\"dl\"><tbody><tr><td>mandatory</td><td>false</td></tr></tbody></table>
           <h2>properties</h2><table class=\"dl\"><tbody><tr><td>contextParams</td><td></td></tr><tr><td>application</td><td>/CompleteTomcat</td></tr><tr><td>listenerPhase</td><td>Initialized</td></tr><tr><td>event</td><td>Initialize</td></tr><tr><td>returnValue</td><td>void</td></tr><tr><td>listenerClass</td><td>org.springframework.web.context.ContextLoaderListener</td></tr><tr><td>label</td><td>Servlet Context: /CompleteTomcat Initialized</td></tr><tr><td>sourceCodeLocation</td><td>org.springframework.web.context.ContextLoaderListener#contextInitialized:107</td></tr><tr><td>ExtraTraceData</td><td></td></tr><tr><td>type</td><td>OperationType[servlet-listener]</td></tr></tbody></table>",
   "frames": []
   
   
    "duration": 431463000,
    "operation_signature": "GET /tomcat.png",
    "id": "93dd05d2-f438-4326-82e9-615a6f6bba09",
    "start_time": 1352189090074082000,
    "desc":
=end
  
  def handle_frames frames,operationid   #frames is array
      frameout=Array.new()
      frames.each do |frame|  #frame is hash
        outunit=Hash.new
        if frame.has_value? operationid
           frame.each do |key,value|
             if key=="desc" 
                outunit[key]=handle_desc value
             elsif key=="frames" 
                outunit[key]=handle_sub_frames value 
             else 
                outunit[key]=value
             end
           end
        elsif frame.has_key? "frames" 
           outunit["frames"]=handle_frames value,operationid 
        end
        frameout << outunit
      end
      frameout    
  end
  
  def handle_sub_frames frames,issearch,matched,keyword
      lens=frames.length
      frameout=Array.new(lens)
      frames.each_index do |index|  #frame is hash
        frameout[index]=Hash.new  unless frameout[index]
		if false== issearch
		  frameout[index]["expanded"]=1
		elsif matched.include? frames[index]["id"]
		  frameout[index]["operation_signature"]=frames[index]["operation_signature"].gsub(/(#{keyword})/i, '<font style="BACKGROUND-COLOR: yellow">\1</font>') 
	      frameout[index]["expanded"]=1
		else
		  frameout[index]["expanded"] = 0
		end
        frames[index].each do |key,value|
          if key=="desc" 
             frameout[index][key]=handle_desc value
          elsif key=="frames" 
             frameout[index][key]=handle_sub_frames value,issearch,matched,keyword
          elsif !frameout[index].has_key? key
             frameout[index][key]=value
          end  
        end 
      end
      frameout   
  end
  
  #return like:
  #<h2>contextParams</h2><table class=\"dl\"><tbody></tbody></table>
  def handle_desc desc   #desc is Array
      outstring=""
      desc.each do |element|
        titles=""
        titles << element["title"] if (element.instance_of? Hash)&&(element.has_key? "title")
        tbody=""
        if element.has_key? "params"
           xhash=element["params"] 
           xhash.each do |key,value|
              tbody << "<tr><td>#{key}<\/td><td>#{value}<\/td><\/tr>"
           end 
        end
	outstring << "<h2>#{titles}<\/h2><table class=\"dl\"><tbody>#{tbody}<\/tbody><\/table>"
      end
   outstring
  end  
end
