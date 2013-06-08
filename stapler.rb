#!/usr/bin/env ruby
require "thor"
require "prawn"

class Stapler < Thor
  desc "join INPUT_PDFs OUTPUT_PDF", "Join INPUT_PDFs in OUTPUT_PDF."
  def join(*pdfs)
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
  
  desc "split INPUT_PDF", "Split each page of INPUT_PDF into a separate PDF."
  def split(first_pdf_path)
    template_page_count = count_pdf_pages(first_pdf_path)
    (1..template_page_count).each do |template_page_number|
      Prawn::Document.generate(first_pdf_path.gsub(/.pdf/, "") + "_page_" + template_page_number.to_s + ".pdf", :skip_page_creation => true) do |pdf|
        pdf.start_new_page(:template => first_pdf_path, :template_page => template_page_number)
      end
    end
  end
  
  # desc "extract INPUT_PDF PAGE_NUMBER", "Split the specified page into a separate PDF."
  # def extract(first_pdf_path, page_number)
  #   Prawn::Document.generate(first_pdf_path.gsub(/.pdf/, "") + "_page_" + page_number.to_s + ".pdf", :skip_page_creation => true) do |pdf|
  #     pdf.start_new_page(:template => first_pdf_path, :template_page => page_number)
  #   end
  # end
  
  private
    def count_pdf_pages(pdf_file_path)
      pdf = Prawn::Document.new(:template => pdf_file_path)
      pdf.page_count
    end
end

Stapler.start(ARGV)