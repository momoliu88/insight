require 'rubygems'

require 'sinatra'
require 'model/receiver'
require 'model/data_processor'
require 'rufus/scheduler'
require 'model/log'
include Receiver
include DataProcessor

Tracelist=Hash.new
log = Log.log
scheduler = Rufus::Scheduler.start_new
scheduler.every '15s' do
  unless Trace.cache.traces.empty?  
  Trace.cache.traces.each do|key,value|
    traces = Array.new
    if (Trace.cache.active_traces_in_file.has_key? key) &&(!Trace.cache.active_traces_in_file[key].empty?)
      Trace.cache.active_traces_in_file[key].each do |k,v|
        trace=Trace.get_trace key,v
        traces << trace
      end
	end
    value.each{|item|traces << item}
    Tracelist[key]=group_by_time Time.now.to_f*1000,15,15*1000,traces
  end
  end
end
#BASE_PATH = "/Users/xiaoqinliu/test-insight/"
BASE_PATH = "/home/liuxiaoqin/test-insight/"
configure do
  set :views,"#{BASE_PATH}/views/"
  set :public_folder,"#{BASE_PATH}/views/public/"
  set :port,4568
end


get '/index' do 
  @users= Trace.cache.traces.keys
  erb :index
end

post '/receive' do 
  pp params.values
  receive params.values
end

get '/traces/:userid' do 
  @userid = params[:userid]
  erb :traces
end

get '/traces_real_time/:name' do
  #return traces in array(json)
  ip=request.ip
  traces=[]
  userid=params[:name]
  return unless Trace.cache.traces.has_key? userid
  out_array_formated Tracelist[userid] if Tracelist[userid]
end

get '/user/:name/index/:index' do
  index=params[:index].to_i
  user = params[:name]
  return unless (index>=0 && index<60)
  array=Tracelist[user] if Tracelist.has_key? user
  return if array == nil || array[index]==nil || array[index]["traces"] ==nil
  traces_at_index array[index] unless array[index]["traces"].empty?
end 

get '/user/:name/traceid/:traceid/keyword/:keyword' do
  userid = params[:name]
  traceid = params[:traceid]
  keyword = params[:keyword]
  pp "#{userid}:#{traceid}:#{keyword}"
  trace = find_trace userid,traceid
  
  pp "search #{keyword}"
  output=trace_detail trace,true,keyword,false if trace
  pp output
  output if output
end
def find_trace userid,traceid
 outcache = true	
 trace = nil
 if Trace.cache.traces.has_key? userid
     Trace.cache.traces[userid].each do |item|
        if item.traceid == traceid
	       trace = item
           outcache = false
	       break
	    end
     end
  end
  if outcache
    begin
      trace=Trace.get_trace userid,traceid
	rescue Exception=> error
	  Log.log.warn("#{error}")
	end
  end
  trace
end
get '/user/:name/traceid/:traceid' do 
  #return a trace detail
  userid=params[:name]
  traceid=params[:traceid]
  outcache=true
  trace = find_trace userid,traceid

  #return unless Trace.cache.traces.has_key? userid
  log.debug("userid: #{userid}\ntraceid: #{traceid}")
  log.debug("#{trace}")
  trace_detail trace,false,nil,false if trace
end
get '/user/:name/traceid/:traceid/intime/keyword/:keyword' do  
  userid = params[:name]
  traceid = params[:traceid]
  keyword = params[:keyword]
  trace = find_trace userid,traceid
  
  pp "search #{keyword}"
  output=trace_detail trace,true,keyword,true if trace
  pp output
  output if output

end
get '/user/:name/groupby/:keyword/search/:searchkeyword' do
  user = params[:name]  
  keyword=params[:keyword] 
  searchkey = params[:searchkeyword]
  traceids = Trace.get_all_traceids_by_userid user,:array,nil
  return unless traceids
  groups = group_at_index_by (keyword,traceids,user,searchkey) unless traceids.empty?
  result = Template.template_groupby groups,keyword,searchkey
  result.to_json if result
end
get '/user/:name/groupby/:keyword' do  
  #return traces in group  
  user = params[:name]  
  keyword=params[:keyword]  
  traceids = Trace.get_all_traceids_by_userid user,:array,nil
  log.debug(traceids)
  return unless traceids
  groups = group_at_index_by (keyword,traceids,user,nil) unless traceids.empty?
  result = Template.template_groupby groups,keyword,nil
  result.to_json if result
end

get '/all_traces/:userid' do
  @userid = params[:userid]
  erb :all_traces
end
get '/alltraces/:userid' do
  traceids = Trace.get_all_traceids_by_userid params[:userid],:map,nil
  traceMap = Template.template_all_traces traceids
  JSON.generate(traceMap) if traceMap;
end
get '/alltraces/:userid/keyword/:keyword' do
  traceids = Trace.get_all_traceids_by_userid params[:userid],:map,params[:keyword]
  traceMap = Template.template_all_traces traceids
  JSON.generate(traceMap) if traceMap;
end



