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

String.class_eval do
  def is_int
    return self.to_i.to_s == self
  end
  
  def is_range
    case
      when self.include?("..")
        a = self.split("..")
        return a.length == 2 && a[0].is_int && a[1].is_int
      when self.include?("...")
        a = self.split("...")
        return a.length == 2 && a[0].is_int && a[1].is_int
      else
        return false
    end
  end
  
  def to_range
    case
      when self.is_range && self.include?("..")
        return self.split("..").inject { |s, e| Range.new(s.to_i, e.to_i) }
      when self.is_range && self.include?("...")
        return self.split("...").inject { |s, e| Range.new(s.to_i, e.to_i) }
      else
        raise TypeError, "Cannot convert " + self + " to range."
    end
  end
end

class Stapler < Thor
  desc "get INPUT_PDF [OUTPUT_PDF] PAGE_NUMBERS", "Create an OUTPUT_PDF containing the specified pages of INPUT_PDF."
  def get(*args)
    pdf_temp_nb_pages = Prawn::Document.new(:template => args[0]).page_count
    pdf_name_prefix = args[0].gsub(/.pdf/, "") + "_page_"

    case
      # stapler get input.pdf
      when args.length == 1
        raise ArgumentError, "Not enough arguments."
        
      # stapler get input.pdf output.pdf
      when args.length == 2 && args[1].include?(".pdf")
        raise ArgumentError, "Not enough arguments."
        
      # stapler get input.pdf 4..42
      when args.length == 2 && args[1].is_range
        range = args[1].to_range
      
      # stapler get input.pdf 4
      when args.length == 2 && args[1].is_int
        range = Range.new(args[1].to_i, args[1].to_i)
      
      # stapler get input.pdf output.pdf 4..42
      when args.length == 3 && args[1].include?(".pdf") && args[2].is_range
        range = args[2].to_range
        
      # stapler get input.pdf output.pdf 4
      when args.length == 3 && args[1].include?(".pdf") && args[2].is_int
        range = Range.new(args[2].to_i, args[2].to_i)
        
      else
        raise ArgumentError, "Invalid arguments."
    end

    (range).each do |i|
      Prawn::Document.generate(pdf_name_prefix + i.to_s + ".pdf", :skip_page_creation => true) do |output|
        output.start_new_page(:template => args[0], :template_page => i)
      end
    end
  end

  desc "join INPUT_PDFS OUTPUT_PDF", "Merge specified INPUT_PDFS into a single OUTPUT_PDF. "
  def join(*pdf_files)
    Prawn::Document.generate(pdf_files[pdf_files.length - 1], :skip_page_creation => true) do |output|
      pdf_files.each do |pdf|
        output.concat(pdf)
      end
    end
  end
  
  desc "split INPUT_PDF", "Split the pages of INPUT_PDF into multiple PDFs."
  def split(pdf_file)
    pdf_temp_nb_pages = Prawn::Document.new(:template => pdf_file).page_count
    pdf_name_prefix = pdf_file.gsub(/.pdf/, "") + "_page_"

    (1..pdf_temp_nb_pages).each do |i|
      Prawn::Document.generate(pdf_name_prefix + i.to_s + ".pdf", :skip_page_creation => true) do |output|
        output.start_new_page(:template => pdf_file, :template_page => i)
      end
    end
  end
end

Stapler.start(ARGV)