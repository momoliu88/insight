require "model/configure"
require "model/template"
require 'tree'
require 'pp'
require 'base64'
require "model/data_processor"
require "json"
require "fileutils"
require "model/hash_extend"
require 'model/trace_cache'
class Trace
  attr_reader :data,:userid,:traceid,:start_time_ns,:start_time,:duration,:type,:frames,:http_response,:http_request,:endpoint,:body_type
  attr_accessor :start_time,:traceid,:body_type
  @@root = Configuration::ROOT
  @@cache = TraceCache.new(1024*64,15*60)
  include DataProcessor
  include Comparable
  IMAGE=["jpeg","png","gif"]
  AUDIO=["mpeg"]
  def initialize data 
    @data = JSON.parse data,:max_nesting => 100
    @userid = @data["user_id"]
    @duration = @data["trace_duration"]
    @traceid = @data["trace_id"]
    @endpoint = @data["endpoint"]
    @type = @data["trace_group"]
    @start_time = @data["trace_start_time"].to_i
    @start_time_ns = @data["trace_start_time_ns"].to_i
    @frames =filter_frames @data["frames"]
    @endpoint = @data["endpoint"]
    @http_response =  @data["http_response"]||nil
    @http_request = @data["http_request"]||nil
   # pp @http_request
	@need_encode = false
  if (@http_request && @http_request.class==Hash)
    filter @http_request,"headers"
    filter @http_request,"cookies"
  end
  if (@http_response && @http_response.class==Hash)
      filter @http_response,"headers"
  end
  
    @frame_tree_root_node = createTree(self)
  end
 #filter frames 
  def filter_frames aFrames
    aFrames.each do |hsFrame|
      hsFrame.each do |key,value|
        if key=="frames"
          filter_frames value
        elsif key=="desc"
          value.each do |e|
              e["params"].delete_invalid_entrys Configuration::INVALID_VALUES,:value  
          end
            value.delete_if do |item|
            item["params"].empty?
          end
        end
      end
    end
    aFrames
  end

  #search operation_id that matched keyword
  def search keyword
  result = Set.new
  matched = Array.new
    @frame_tree_root_node.each{|node|
    if node.content =~ /#{keyword}/i
      matched << node.name
    end
  }  
  @frame_tree_root_node.each{|node|
    if node.is_root?
      result << node.name
    elsif matched.include? node.name
    result << node.name #add id
    node.parentage.each{|item|
      result << item.name
    }
    end
  }
  @frame_tree_root_node.print_tree
  result
  end
  def get_body_type filename
    result = %x(file -b #{filename})
	IMAGE.each{|item|
	  if result =~ /#{item}/i
		@need_encode = true
	    return "image/#{item}"
	  end
	}
	AUDIO.each{|item|
	  if result =~ /#{item}/i
		@need_encode = true
	    return "audio/#{item}"
	  end
	}
#  return :abnormal unless @http_response['contentLength']
#  return :abnormal if @http_response['contentLength'] == '-1'
  :normal
  end
  def filter map,key
    return unless (map.has_key? key)
    map[key]=format(map[key])
    map.delete_invalid_entrys Configuration::INVALID_VALUES,:value
    map.delete_invalid_entrys Configuration::INVALID_KEYS,:key
  end 
  def read_body 
  begin
    body = File.read(body_file_name)
    return Base64.encode64(body) if @need_encode
    body.delete("\000")
  rescue Exception => err
    Log.log.warn("#{err}")
    ""
  end
  end
  def self.active_time
    Configuration::ACTIVE_TIME
  end
  def self.cache
    @@cache
  end
  
  def body_file_name
    filename()+"_body"
  end
  def write_body string
    p "string #{string.length}"
    str = Base64.decode64(string)
    if @http_response['contentLength']
      content_len = @http_response['contentLength'].to_i
  end
    file = body_file_name
    f = File.new(file,'w')
    str = str[0...content_len]if content_len and content_len !=-1
    f.write(str)
    f.close
  file
  end
  def get_http_response_headers
    (@http_response==nil)?nil:@http_response["headers"]
  end
  def get_http_request_headers
    (@http_request==nil)?nil:@http_request["headers"]
  end
  def isHttp?
    return true if @type.casecmp("http")
    false
  end
  
  def self.users
    @@traces.keys
  end
  def self.get_traces_by_user user
    @@traces[user]
  end
  #as trace active time's 15min(max),so check if the trace is expire
  def expires? 
    (Time.now.to_f*1000 - Trace.active_time) > @start_time
  end
  
  def filename
    date = Time.at(@start_time.to_f/1000.0).strftime("%Y-%m-%d");
    File.join(@@root,@userid,date,@traceid)    
  end
  def persist
     file = filename()
     dir = File.dirname(file)    
     FileUtils.mkdir_p dir unless  File.exists? dir
     File.open(file,'w') do |f|
       f.puts JSON.pretty_generate(@data,:max_nesting => 100)  
     end
   if @http_response
    body_file = write_body @http_response["body"] if @http_response["body"]
      @body_type = get_body_type body_file if body_file
     end
  end
  #actually not here 
   def dispatch userid
    traces = Trace.get_traces_by_user userid
    group_by_time Time.now.to_f*1000,15,15*1000,traces
  end 

  def self.get_trace userid,traceid
    dirname = Trace.get_user_dir_by_userid userid
    files = DataProcessor::find_file dirname,traceid
    p "may be some error in your program,as traceid is unique." if files.length >1
    unless files.empty?
      return  Trace.get_trace_from_file files[0]
    end
    return nil
  end
  
  def <=> o 
    self.duration <=> o.duration
  end 
 
  def self.get_trace_from_file path
    data = File.read(path)
    trace = Trace.new data
  trace.body_type = trace.get_body_type path+"_body"
  trace
  end
  def self.get_user_dir_by_userid userid
    File.join(@@root,userid) 
  end
  def self.get_all_traceids_by_userid userid,type,keyword
    dirname = Trace.get_user_dir_by_userid userid
    return unless File.exists? dirname
    traceids = Hash.new
    traces = Array.new
    DataProcessor::traverse_dir dirname,traceids,traces,keyword
    #p "traceid"
    #return Template.template_all_traces traceids   #=>{date=>[trace]}
    if type == :map
      return traceids
    elsif type == :array
      return traces
    end
  end
end

