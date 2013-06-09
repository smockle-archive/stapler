require File.expand_path("../../extensions/string", __FILE__)
require "test/unit"
 
class TestString < Test::Unit::TestCase
  def test_is_int
    assert !("four".is_int)
    assert !("4.444".is_int)
    assert !("4..4".is_int)
    assert "4".is_int
  end
  
  def test_is_range
    assert !("four".is_range)
    assert !("4.444".is_range)
    assert !("4".is_range)
    assert !("4..".is_range)
    assert !("4...".is_range)
    assert !("4..8..15".is_range)
    assert !("4...8...15".is_range)
    assert "4..8".is_range
    assert "4...8".is_range
  end
  
  def test_to_range
    assert true
  end
end