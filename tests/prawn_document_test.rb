require File.expand_path("../../extensions/prawn_document", __FILE__)
require "test/unit"
 
class TestPrawnDocument < Test::Unit::TestCase
  def test_concat
    Prawn::Document.generate(File.expand_path("../../tests/prawn_document_test_a.pdf", __FILE__)) do |pdf|
      pdf.text("PAGE_A")
    end
    Prawn::Document.generate(File.expand_path("../../tests/prawn_document_test_b.pdf", __FILE__)) do |pdf|
      pdf.text("PAGE_B")
    end
    Prawn::Document.generate(File.expand_path("../../tests/prawn_document_test_c.pdf", __FILE__), :skip_page_creation => true) do |pdf|
      pdf.start_new_page(:template => File.expand_path("../../tests/prawn_document_test_b.pdf", __FILE__))
      pdf.concat(File.expand_path("../../tests/prawn_document_test_a.pdf", __FILE__))
    end
    
    assert_equal Prawn::Document.new(:template => File.expand_path("../../tests/prawn_document_test_a.pdf", __FILE__)).page_count, 1
    assert_equal Prawn::Document.new(:template => File.expand_path("../../tests/prawn_document_test_b.pdf", __FILE__)).page_count, 1
    assert_equal Prawn::Document.new(:template => File.expand_path("../../tests/prawn_document_test_c.pdf", __FILE__)).page_count, 2
    
    File.delete(File.expand_path("../../tests/prawn_document_test_a.pdf", __FILE__))
    File.delete(File.expand_path("../../tests/prawn_document_test_b.pdf", __FILE__))
    File.delete(File.expand_path("../../tests/prawn_document_test_c.pdf", __FILE__))
  end
end