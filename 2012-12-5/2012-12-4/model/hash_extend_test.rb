require "hash_extend"
require "test/unit"
require "test/unit/ui/console/testrunner"
class HashExtendTest < Test::Unit::TestCase
	def setup
		@data={ "attributes"=>[],
        "servletName"=> "Unknown","abc"=>"123"}
	end
	def test_format
		@data.delete_invalid_entrys ["0","unknown"],:value
		expected={"abc"=>"123"}
		assert_equal(expected,@data)
		@data.delete_invalid_entrys ["abc"],:key
		assert_equal({},@data)
	end
  
end
Test::Unit::UI::Console::TestRunner.run(HashExtendTest)
