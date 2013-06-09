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