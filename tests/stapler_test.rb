load File.expand_path("../../stapler", __FILE__)
require "test/unit"

class TestStapler < Test::Unit::TestCase
  def setup
    @a = File.expand_path("../../tests/stapler_test_a.pdf", __FILE__)
    @b = File.expand_path("../../tests/stapler_test_b.pdf", __FILE__)
    @c = File.expand_path("../../tests/stapler_test_c.pdf", __FILE__)
    @input = File.expand_path("../../tests/stapler_test_input.pdf", __FILE__)
    @output = File.expand_path("../../tests/stapler_test_output.pdf", __FILE__)
    @stapler = Stapler.new
    
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
    @stapler = nil
  end
  
  def test_get
    # stapler get
    exception = assert_raise(ArgumentError) { @stapler.get() }
    assert_equal "Invalid arguments.", exception.message
    
    # stapler get input.pdf
    exception = assert_raise(ArgumentError) { @stapler.get(@input) }
    assert_equal "Not enough arguments.", exception.message
      
    # stapler get input.pdf output.pdf
    exception = assert_raise(ArgumentError) { @stapler.get(@input, @output) }
    assert_equal "Not enough arguments.", exception.message
      
    # stapler get input.pdf output.pdf 2..3
    @stapler.get(@input, @output, "2..3")
    assert File.exist?(@output)
    assert_equal Prawn::Document.new(:template => @output).page_count, 2
    
    # stapler get input.pdf output.pdf 2
    @stapler.get(@input, @output, "2")
    assert File.exist?(@output)
    assert_equal Prawn::Document.new(:template => @output).page_count, 1
  end
  
  def test_insert
    # stapler insert
    exception = assert_raise(ArgumentError) { @stapler.insert() }
    assert_equal "Invalid arguments.", exception.message
    
    # stapler insert input.pdf
    exception = assert_raise(ArgumentError) { @stapler.insert(@input) }
    assert_equal "Not enough arguments.", exception.message
         
    # stapler insert input.pdf insert.pdf
    exception = assert_raise(ArgumentError) { @stapler.insert(@input, @a) }
    assert_equal "Not enough arguments.", exception.message
      
    # stapler insert input.pdf insert.pdf output.pdf
    exception = assert_raise(ArgumentError) { @stapler.insert(@input, @a, @output) }
    assert_equal "Not enough arguments.", exception.message
      
    # stapler insert input.pdf insert.pdf output.pdf 2
    @stapler.insert(@input, @a, @output, "2")
    assert_equal Prawn::Document.new(:template => @a).page_count, 1
    assert_equal Prawn::Document.new(:template => @input).page_count, 3
    assert File.exist?(@output)
    assert_equal Prawn::Document.new(:template => @output).page_count, 4
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