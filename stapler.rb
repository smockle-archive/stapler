#!/usr/bin/env ruby
require "thor"
require "prawn"

class Stapler < Thor
  desc "merge INPUT_PDFs OUTPUT_PDF", "Save the concatenation of INPUT_PDFs to OUTPUT_PDF."
  def merge(*pdfs)
    first_pdf_path = pdfs.delete_at(0)
    destination = pdfs.delete_at(pdfs.length - 1)
    
    Prawn::Document.generate(destination, :template => first_pdf_path) do |pdf|
      pdfs.each do |pdf_path|
        pdf.go_to_page(pdf.page_count)
        template_page_count = count_pdf_pages(pdf_path)
        (1..template_page_count).each do |template_page_number|
          pdf.start_new_page(:template => pdf_path, :template_page => template_page_number)
        end
      end
    end
  end
  
  private
    def count_pdf_pages(pdf_file_path)
      pdf = Prawn::Document.new(:template => pdf_file_path)
      pdf.page_count
    end
end

Stapler.start(ARGV)