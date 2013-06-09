require File.expand_path("../../extensions/string", __FILE__)
require "test/unit"
 
class TestString < Test::Unit::TestCase
  def test_is_int
    assert !("four".is_int)
    assert !("4.4".is_int)
    assert !("4..4".is_int)
    assert "4".is_int
  end
  
  def test_is_range
    assert !("four".is_range)
    assert !("4.4".is_range)
    assert !("4".is_range)
    assert !("4..".is_range)
    assert !("4...".is_range)
    assert !("4..8..15".is_range)
    assert !("4...8...15".is_range)
    assert "4..8".is_range
    assert "4...8".is_range
  end
  
  def test_to_range
    exception = assert_raise(TypeError) { "four".to_range }
    assert_equal("Cannot convert four to range.", exception.message)
    exception = assert_raise(TypeError) { "4.4".to_range }
    assert_equal("Cannot convert 4.4 to range.", exception.message)
    exception = assert_raise(TypeError) { "4".to_range }
    assert_equal("Cannot convert 4 to range.", exception.message)
    exception = assert_raise(TypeError) { "4..".to_range }
    assert_equal("Cannot convert 4.. to range.", exception.message)
    exception = assert_raise(TypeError) { "4...".to_range }
    assert_equal("Cannot convert 4... to range.", exception.message)
    exception = assert_raise(TypeError) { "4..8..15".to_range }
    assert_equal("Cannot convert 4..8..15 to range.", exception.message)
    exception = assert_raise(TypeError) { "4...8...15".to_range }
    assert_equal("Cannot convert 4...8...15 to range.", exception.message)
    assert_equal "4..8".to_range, 4..8
    assert_equal "4...8".to_range, 4...8
  end
end