require 'sinatra'

configure do
	set :port,5555
end
get '/port' do
	response.set_cookie("my_cookie",{:value=>"123",:path => "myPath",:expires=>Time.new})
	p "port #{request.env}"
end
