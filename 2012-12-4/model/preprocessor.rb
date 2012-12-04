# preprocessor to preprocess 
require 'json'
module Preprocessor
	def validate_json? str
		begin
			JSON.parse(str)
			return true 
		rescue Exception => e
			return false
		end
	end
end

if __FILE__ == $0
	include Preprocessor
	str='123:{er}'
	puts	validate_json?str
	str='{"a":"b"}'
	puts validate_json?str
end
