load File.expand_path("../../stapler", __FILE__)
require "test/unit"

class TestStapler < Test::Unit::TestCase
  def setup
    @a = File.expand_path("../../tests/stapler_test_a.pdf", __FILE__)
    @b = File.expand_path("../../tests/stapler_test_b.pdf", __FILE__)
    @c = File.expand_path("../../tests/stapler_test_c.pdf", __FILE__)
    @input = File.expand_path("../../tests/stapler_test_input.pdf", __FILE__)
    @output = File.expand_path("../../tests/stapler_test_output.pdf", __FILE__)
    @missing = File.expand_path("../../tests/stapler_test_missing.pdf", __FILE__)
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
    if File.exist?(@missing) then File.delete(@missing) end
    @stapler = nil
  end
  
  def test_get
    # stapler get
    exception = assert_raise(ArgumentError) { @stapler.get() }
    assert_equal "Not enough arguments.", exception.message
    
    # stapler get input.pdf
    exception = assert_raise(ArgumentError) { @stapler.get(@input) }
    assert_equal "Not enough arguments.", exception.message
      
    # stapler get input.pdf output.pdf
    exception = assert_raise(ArgumentError) { @stapler.get(@input, @output) }
    assert_equal "Not enough arguments.", exception.message

    # stapler get missing.pdf *
    exception = assert_raise(ArgumentError) { @stapler.get(@missing, "2") }
    assert_equal "Specified file " + @missing + " does not exist.", exception.message

    # stapler get input.pdf -4000..3
    exception = assert_raise(RangeError) { @stapler.get(@input, "-4000..3") }
    assert_equal "Specified page " + "-4000" + " does not exist.", exception.message

    # stapler get input.pdf 2..4000
    exception = assert_raise(RangeError) { @stapler.get(@input, "2..4000") }
    assert_equal "Specified page " + "4000" + " does not exist.", exception.message

    # stapler get input.pdf 4000
    exception = assert_raise(RangeError) { @stapler.get(@input, "4000") }
    assert_equal "Specified page " + "4000" + " does not exist.", exception.message

    # stapler get input.pdf 2..3
    @stapler.get(@input, "2..3")
    out = "output.pdf"
    assert File.exist?(out)
    assert_equal Prawn::Document.new(:template => out).page_count, 2
    if File.exist?(out) then File.delete(out) end
   
    # stapler get input.pdf 2
    @stapler.get(@input, "2")
    out = "output.pdf"
    assert File.exist?(out)
    assert_equal Prawn::Document.new(:template => out).page_count, 1
    if File.exist?(out) then File.delete(out) end

    # stapler get input.pdf output.pdf 2..3
    @stapler.get(@input, @output, "2..3")
    assert File.exist?(@output)
    assert_equal Prawn::Document.new(:template => @output).page_count, 2
    if File.exist?(@output) then File.delete(@output) end
    
    # stapler get input.pdf output.pdf 2
    @stapler.get(@input, @output, "2")
    assert File.exist?(@output)
    assert_equal Prawn::Document.new(:template => @output).page_count, 1
  end
  
  def test_insert
    # stapler insert
    exception = assert_raise(ArgumentError) { @stapler.insert() }
    assert_equal "Not enough arguments.", exception.message
    
    # stapler insert input.pdf
    exception = assert_raise(ArgumentError) { @stapler.insert(@input) }
    assert_equal "Not enough arguments.", exception.message
         
    # stapler insert input.pdf insert.pdf
    exception = assert_raise(ArgumentError) { @stapler.insert(@input, @a) }
    assert_equal "Not enough arguments.", exception.message
    
    # stapler insert input.pdf insert.pdf output.pdf
    exception = assert_raise(ArgumentError) { @stapler.insert(@input, @a, @output) }
    assert_equal "Not enough arguments.", exception.message
    
    # stapler insert missing.pdf *
    exception = assert_raise(ArgumentError) { @stapler.insert(@missing, @a, @output, "2") }
    assert_equal "Specified file " + @missing + " does not exist.", exception.message
    
    # stapler insert input.pdf missing.pdf *
    exception = assert_raise(ArgumentError) { @stapler.insert(@input, @missing, @output, "2") }
    assert_equal "Specified file " + @missing + " does not exist.", exception.message

    # stapler insert input.pdf insert.pdf 4000
    exception = assert_raise(IndexError) { @stapler.insert(@input, @a, "4000") }
    assert_equal "Specified page " + "4000" + " does not exist.", exception.message

    # stapler insert input.pdf insert.pdf 2      
    @stapler.insert(@input, @a, "2")
    out = "output.pdf"
    assert_equal Prawn::Document.new(:template => @a).page_count, 1
    assert_equal Prawn::Document.new(:template => @input).page_count, 3
    assert File.exist?(out)
    assert_equal Prawn::Document.new(:template => out).page_count, 4
    if File.exist?(out) then File.delete(out) end

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
    # stapler join
    exception = assert_raise(ArgumentError) { @stapler.join() }
    assert_equal "Not enough arguments.", exception.message
    
    # stapler join output.pdf
    exception = assert_raise(ArgumentError) { @stapler.join(@output) }
    assert_equal "Not enough arguments.", exception.message
    
    # stapler join missing.pdf *
    exception = assert_raise(ArgumentError) { @stapler.join(@missing, @b, @output) }
    assert_equal "Specified file " + @missing + " does not exist.", exception.message
    
    # stapler join * missing.pdf *
    exception = assert_raise(ArgumentError) { @stapler.join(@a, @missing, @output) }
    assert_equal "Specified file " + @missing + " does not exist.", exception.message
        
    # stapler join a.pdf output.pdf
    @stapler.join(@a, @output)
    assert_equal Prawn::Document.new(:template => @a).page_count, 1
    assert File.exist?(@output)
    assert_equal Prawn::Document.new(:template => @output).page_count, 1
    if File.exist?(@output) then File.delete(@output) end
    
    # stapler join a.pdf b.pdf output.pdf
    @stapler.join(@a, @b, @output)
    assert_equal Prawn::Document.new(:template => @a).page_count, 1
    assert_equal Prawn::Document.new(:template => @b).page_count, 1
    assert File.exist?(@output)
    assert_equal Prawn::Document.new(:template => @output).page_count, 2
  end
  
  def test_remove
    # stapler remove
    exception = assert_raise(ArgumentError) { @stapler.remove() }
    assert_equal "Not enough arguments.", exception.message
    
    # stapler remove input.pdf
    exception = assert_raise(ArgumentError) { @stapler.remove(@input) }
    assert_equal "Not enough arguments.", exception.message
      
    # stapler remove input.pdf output.pdf
    exception = assert_raise(ArgumentError) { @stapler.remove(@input, @output) }
    assert_equal "Not enough arguments.", exception.message
    
    # stapler remove missing.pdf *
    exception = assert_raise(ArgumentError) { @stapler.remove(@missing, "2") }
    assert_equal "Specified file " + @missing + " does not exist.", exception.message

    # stapler remove input.pdf -4000..3
    exception = assert_raise(RangeError) { @stapler.remove(@input, "-4000..3") }
    assert_equal "Specified page " + "-4000" + " does not exist.", exception.message

    # stapler remove input.pdf 2..4000
    exception = assert_raise(RangeError) { @stapler.remove(@input, "2..4000") }
    assert_equal "Specified page " + "4000" + " does not exist.", exception.message

    # stapler remove input.pdf 4000
    exception = assert_raise(RangeError) { @stapler.remove(@input, "4000") }
    assert_equal "Specified page " + "4000" + " does not exist.", exception.message

    # stapler remove input.pdf 2..3
    @stapler.remove(@input, "2..3")
    out = "output.pdf"
    assert_equal Prawn::Document.new(:template => @input).page_count, 3
    assert File.exist?(out)
    assert_equal Prawn::Document.new(:template => out).page_count, 1
    if File.exist?(out) then File.delete(out) end

    # stapler remove input.pdf 2
    @stapler.remove(@input, "2")
    out = "output.pdf"
    assert_equal Prawn::Document.new(:template => @input).page_count, 3
    assert File.exist?(out)
    assert_equal Prawn::Document.new(:template => out).page_count, 2
    if File.exist?(out) then File.delete(out) end

    # stapler remove input.pdf output.pdf 2..3
    @stapler.remove(@input, @output, "2..3")
    assert_equal Prawn::Document.new(:template => @input).page_count, 3
    assert File.exist?(@output)
    assert_equal Prawn::Document.new(:template => @output).page_count, 1
    if File.exist?(@output) then File.delete(@output) end

    # stapler remove input.pdf output.pdf 2
    @stapler.remove(@input, @output, "2")
    assert_equal Prawn::Document.new(:template => @input).page_count, 3
    assert File.exist?(@output)
    assert_equal Prawn::Document.new(:template => @output).page_count, 2
  end
  
  def test_split
    # stapler split
    exception = assert_raise(ArgumentError) { @stapler.split() }
    assert_equal "wrong number of arguments (0 for 1)", exception.message
    
    # stapler split missing.pdf
    exception = assert_raise(ArgumentError) { @stapler.split(@missing) }
    assert_equal "Specified file " + @missing + " does not exist.", exception.message
    
    # stapler split input.pdf
    @stapler.split(@input)
    x = "stapler_test_input_page_1.pdf"
    y = "stapler_test_input_page_2.pdf"
    z = "stapler_test_input_page_3.pdf"
    assert File.exist?(x)
    assert File.exist?(y)
    assert File.exist?(z)
    if File.exist?(x) then File.delete(x) end
    if File.exist?(y) then File.delete(y) end
    if File.exist?(z) then File.delete(z) end
  end
end