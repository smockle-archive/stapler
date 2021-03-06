require "test_helper.rb"

class TestPrawnDocument < MiniTest::Test
  def setup
    @a = "prawn_document_test_a.pdf"
    @b = "prawn_document_test_b.pdf"
    @c = "prawn_document_test_c.pdf"
    
    Prawn::Document.generate(@a) do |pdf|
      pdf.text("PAGE_A")
    end
    Prawn::Document.generate(@b) do |pdf|
      pdf.text("PAGE_B")
    end
    Prawn::Document.generate(@c, :skip_page_creation => true) do |pdf|
      pdf.start_new_page(:template => @b)
      pdf.concat(@a)
    end
  end
  
  def teardown
    File.delete(@a)
    File.delete(@b)
    File.delete(@c)
  end
  
  def test_concat
    assert_equal Prawn::Document.new(:template => @a).page_count, 1
    assert_equal Prawn::Document.new(:template => @b).page_count, 1
    assert_equal Prawn::Document.new(:template => @c).page_count, 2
  end
end