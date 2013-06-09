#!/usr/bin/env ruby
require "thor"
require "prawn"

Prawn::Document.class_eval do
  def concat(pdf_file)
    if File.exists?(pdf_file)
      pdf_temp_nb_pages = Prawn::Document.new(:template => pdf_file).page_count
      (1..pdf_temp_nb_pages).each do |i|
        self.start_new_page(:template => pdf_file, :template_page => i)
      end
    end
  end
end

class Stapler < Thor
  desc "join INPUT_PDFs OUTPUT_PDF", "Join INPUT_PDFs in OUTPUT_PDF."
  def join(*pdf_files)
    Prawn::Document.generate(pdf_files[pdf_files.length - 1], :skip_page_creation => true) do |output|
      pdf_files.each do |pdf|
        output.concat(pdf)
      end
    end
  end
  
  desc "split INPUT_PDF", "Split each page of INPUT_PDF into a separate PDF."
  def split(pdf_file)
    pdf_temp_nb_pages = Prawn::Document.new(:template => pdf_file).page_count
    pdf_name_prefix = pdf_file.gsub(/.pdf/, "") + "_page_"
    (1..pdf_temp_nb_pages).each do |i|
      Prawn::Document.generate(pdf_name_prefix + i.to_s + ".pdf", :skip_page_creation => true) do |output|
        output.start_new_page(:template => pdf_file, :template_page => i)
      end
    end
  end
  
  # desc "extract INPUT_PDF PAGE_NUMBER", "Split the specified page into a separate PDF."
  # def extract(first_pdf_path, page_number)
  #   Prawn::Document.generate(first_pdf_path.gsub(/.pdf/, "") + "_page_" + page_number.to_s + ".pdf", :skip_page_creation => true) do |pdf|
  #     pdf.start_new_page(:template => first_pdf_path, :template_page => page_number)
  #   end
  # end
end

Stapler.start(ARGV)