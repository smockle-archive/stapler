load File.expand_path("../../stapler", __FILE__)
require "test/unit"

class TestStapler < Test::Unit::TestCase
  def setup
    @a = File.expand_path("../../tests/stapler_test_a.pdf", __FILE__)
    @b = File.expand_path("../../tests/stapler_test_b.pdf", __FILE__)
    @c = File.expand_path("../../tests/stapler_test_c.pdf", __FILE__)
    @input = File.expand_path("../../tests/stapler_test_input.pdf", __FILE__)
    @output = File.expand_path("../../tests/stapler_test_output.pdf", __FILE__)
    
    Prawn::Document.generate(@a) do |pdf|
      pdf.text("PAGE_A")
    end
    Prawn::Document.generate(@b) do |pdf|
      pdf.text("PAGE_B")
    end
    Prawn::Document.generate(@c) do |pdf|
      pdf.text("PAGE_C")
    end
    Prawn::Document.generate(@input, :skip_page_creation => true) do |pdf|
      pdf.start_new_page(:template => @a)
      pdf.start_new_page(:template => @b)
      pdf.start_new_page(:template => @c)      
    end
  end
  
  def teardown
    File.delete(@a)
    File.delete(@b)
    File.delete(@c)
    File.delete(@input)
    if File.exist?(@output) then File.delete(@output) end
  end
  
  def test_get
    # stapler get input.pdf
    exception = assert_raise(ArgumentError) { Stapler.new.get(@input) }
    assert_equal "Not enough arguments.", exception.message
      
    # stapler get input.pdf output.pdf
    exception = assert_raise(ArgumentError) { Stapler.new.get(@input, @output) }
    assert_equal "Not enough arguments.", exception.message
      
    # stapler get input.pdf 4..42
    assert true
    
    # stapler get input.pdf 4
    assert true
    
    # stapler get input.pdf output.pdf 4..42
    assert true
    
    # stapler get input.pdf output.pdf 4
    assert true
  end
  
  def test_insert
    assert true
  end
  
  def test_join
    assert true
  end
  
  def test_remove
    assert true
  end
  
  def test_split
    assert true
  end
end