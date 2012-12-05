require 'model/configure.rb'
require 'shellwords'
require 'model/log'
require 'model/string_extend'
require 'model/template'
require 'json'

include Template
module DataProcessor
  
  def self.find_file path,filename
    _path = Shellwords.escape path
    cmd = "find #{_path} -name '#{filename}'"
    (`#{cmd}`).split("\n")
  end 
  
  def self.traverse_dir path,map,array,keyword
    if File.directory? path
      Dir.foreach(path) do |file|
        if file!="." and file!=".."
          traverse_dir(File.join(path,file),map,array,keyword)
        end
      end
    else
      dirname = File.dirname(path)
      key = dirname.get_lastpart_name
	  traceid = nil
	  trace = nil
	  unless path.get_lastpart_name.include?"body"
	    traceid = path.get_lastpart_name
		trace = Trace.get_trace_from_file path
	  end
	  array << traceid if traceid
	  map[key] = Array.new unless map[key]
	  if traceid and trace
	    _inner_map = Hash.new
		_inner_map["traceid"]=traceid
		_inner_map["endpoint"]=trace.endpoint
		if keyword and trace.endpoint =~ /#{keyword}/i
	      _inner_map["matched"]=1
			_inner_map["endpoint"]=trace.endpoint.gsub(/(#{keyword})/i,'<font style="BACKGROUND-COLOR:yellow">\1</font>')
		else
		  _inner_map["matched"]=0
		end
		map[key] << _inner_map
	  end 
    end
  end
=begin
  #return:like [
                {"cookie"=>123,"traces"=>[traceids],"list"=>[{"START"=>"Wed Nov 14 23:28:57 GST 2012","DURATION"=>1992000,"TRACEID"=>"4ed7448a-58c6-4efb-bb0e-e3d806e8372d","LABEL"=>"GET /asf-logo.png","ERROR"=>"OK"},{"START"=>"Wed Nov 14 21:53:10 GST 2012", "DURATION"=>3694000,"TRACEID"=>"fde97917-d5c3-4665-8475-55a901f45c94","LABEL"=>"GET /favicon.ico","ERROR"=>"OK"}]},
                {"cookie"=>"http_resp","traces"=>["5e659a15-4cf0-4263-aed8-ecdb0d476c85"],"list"=>[{"START"=>"Wed Nov 14 16:53:06 GST 2012","DURATION"=>4374000,"TRACEID"=>"5e659a15-4cf0-4263-aed8-ecdb0d476c85","LABEL"=>"GET /","ERROR"=>"OK"}]}
				.......
				]
=end
  def group_at_index_by keyword,traces,userid,searchkeyword
    groups=Array.new
    traces.each do |id|
	  trace =Trace.get_trace userid,id
  	  value=group_kind keyword,trace
  	  add_to_group(keyword,value,groups,trace,searchkeyword) if nil != value
    end 
	groups
  end
      
  def create_map keyword,value,trace,searchkey
     map = Hash.new
     infos=Hash.new
     map[keyword] = value
     #infos=handle_trace trace
	 _inner_map = Hash.new
	 _inner_map["endpoint"]=trace.endpoint
	 _inner_map["id"] = trace.traceid
	 _inner_map["matched"]=0
	 if searchkey and trace.endpoint =~ /#{searchkey}/i
	   _inner_map["matched"] = 1
	 end
     map["traces"] = [_inner_map]
     #map["list"]=[infos]
     map
  end 
    
  def add_to_group keyword,value,groups,trace,searchkeyword
    finded = false
    groups.each do |group|
      if value.eql? group[keyword]
       # group["traces"] << trace.traceid 
		_inner_map = Hash.new
		_inner_map["endpoint"]=trace.endpoint
		_inner_map["matched"]=0
		if searchkeyword
		  if _inner_map["endpoint"] =~ /#{searchkeyword}/i
		    _inner_map["matched"]=1
		  end 
		end
		_inner_map["id"] = trace.traceid
  	    group["traces"] << _inner_map
		#(handle_trace trace)
        finded = true
        break
      end 
    end
    return if finded == true
    map = create_map keyword,value,trace,searchkeyword
    groups << map
  end
  
  def handle_trace trace
  	infos=Hash.new
  	infos["START"]=Time.at(trace.start_time/1000).strftime("%a %b %d %H:%M:%S GST %Y")
  	infos["DURATION"] =trace.duration #ns
  	infos["TRACEID"]=trace.traceid
  	infos["LABEL"]=trace.endpoint
  	if trace.type == "LIFECYLE"
  	  infos["ERROR"] = "OK";
  	else
  	  infos["ERROR"]= trace.http_response["statusCode"].to_i<500 ? "OK" : "ERROR"
  	end  
	infos
   end
  	
  def group_kind keyword,trace
    results=nil
    return results=trace.data[keyword] if  trace.data.has_key? keyword
    if  nil != trace.http_response
  	return results=trace.http_response[keyword] if  trace.http_response.has_key? keyword
  	return results=trace.get_http_response_headers[keyword] if  trace.get_http_response_headers.has_key? keyword
    end
    if  nil != trace.http_response
  	return results=trace.http_request[keyword] if  trace.http_request.has_key? keyword
  	return results=trace.get_http_request_headers[keyword] if  trace.get_http_request_headers.has_key? keyword
    end
    return results="UNKNOWN"
  end
  
 
  #return  max duration in traces(Array)
  def max_duration traces
    traces_max=0
	traces.each_index do |index|
		traces_max=traces[index].duration unless traces_max>traces[index].duration
		end
	traces_max
  end
  
  #start_time:generally current time
  #total_time:in minutes
  #interval: 15*1000 ms fixed
  #traces:array
  #return:like [{"duration":"2012-10-1 10:18:20~10-1 10:18:34",traces:[trace1,trace2...]}
  #  			{"duration":"2012-10-1 10:18:35~10-1 10:18:50",traces:[trace5,trace7...]}]
  def group_by_time start_time,total_time,interval,traces
    len = total_time*60*1000/interval
    begin_time = start_time-total_time*60*1000 #ms
    array = Array.new(len)
    (0..array.length-1).each do |k|
      array[k] = Hash.new
	  array[k]["times"]=[] unless array[k]["times"]
      _start = (begin_time+k*interval).to_f
      _end = (_start+interval).to_f
	  array[k]["times"]<< _start
	  array[k]["times"]<< _end
	  array[k]["duration"]=Time.at(_start/1000.0).strftime("%Y-%m-%d %H:%M:%S")+" ~ "+Time.at(_end/1000.0).strftime("%Y-%m-%d %H:%M:%S")
    end
   
    traces.each_index do |idx|
      trace = traces[idx]
      index = ((start_time - trace.start_time).to_f/interval).floor
      if index >= 0 && index < len
        array[len-1-index]["traces"]=[] unless array[len-1-index]["traces"]
        array[len-1-index]["traces"] << trace
      else
        traces[idx] = nil
      end
    end
    traces.delete_if {|k| k == nil}
    array
  end
  
  def out_array_formated traceArr
	return if traceArr == nil
    lens=traceArr.length
    out_array=Array.new(lens)
   	(0..lens-1).each do |k|
        out_array[k]=Hash.new unless out_array[k]
        unless traceArr[k]["traces"]
            out_array[k]["y"]=0
        else
               out_array[k]["duration"]=traceArr[k]["duration"]
			   out_array[k]["y"]=max_duration(traceArr[k]["traces"])
			   out_array[k]["tooltip"]=template_tooltip(traceArr[k]["traces"],traceArr[k]["times"][0],traceArr[k]["times"][1])
        end
    end
    out_array.to_json 
  end
  
   #input traces(array)
   #output traces at index
   #like :[{"tracename":"get ***","starttime":"2012-11-18","duration":"10000000","status":"ok"},{...}]
   def traces_at_index hash
    leth=hash["traces"].length
    trsout=Array.new(leth+1)
	array=hash["traces"]
	trsout.each_index do |index|
	    trsout[index]=Hash.new unless trsout[index]
		if index==0   
		   trsout[index]["TIMESTR"]=hash["duration"]
		   else
		       trsout[index]["START"]=Time.at(array[index-1].start_time/1000).strftime("%a %b %d %H:%M:%S GST %Y")
		       trsout[index]["DURATION"] =array[index-1].duration #ns
		       trsout[index]["TRACEID"]=array[index-1].traceid
			   trsout[index]["LABEL"]=array[index-1].endpoint
			   if array[index-1].type == "LIFECYLE"
			     trsout[index]["ERROR"] = "OK";
			   else
		         trsout[index]["ERROR"]= array[index-1].http_response["statusCode"].to_i<500 ? "OK" : "ERROR"
			   end
		   end
	    end 		
	 trsout.to_json
	end 
  
  def format array
    return array unless array.instance_of? Array
    map = Hash.new 
    array.each do |e|
      raise "#{e} is not a hashmap" unless e.instance_of? Hash
      name = e["name"]
      value = e["value"]
      e.clear
      map[name]=value
    end
    map
  end 
  
  def trace_detail trace,isSearch,keyword,isInTime
    outputs=templater_trace trace,isSearch,keyword,isInTime
	#  outputs.to_json
	JSON.pretty_generate(outputs,:max_nesting => 100) 
	#:max_nesting => 100

  end
  
  def get_all_traceids  userid
      traceids_all=Trace.get_all_traceids_by_userid userid
	  traceids_all.to_json
  end

  def get_all_traces userid
	  hash=Trace.get_all_traceids_by_userid userid
	  traces=Array.new
	  hash.each do |k,v|
		  v.each do|traceid|
			  traces<<(Trace.get_trace userid,traceid)
		  end
	  end
	  traces
  end
  def createTree(trace)
    root_node = Tree::TreeNode.new(trace.traceid,trace.endpoint)
    recursive(trace.frames,root_node)
    root_node
  end

  def recursive(frames,node)
    return unless frames
    frames.each{|frame|
	  chid_node = Tree::TreeNode.new(frame["id"],frame["operation_signature"])
	  recursive(frame["frames"],chid_node)if frame["frames"]
	  node << chid_node
    }
    node
  end

end
