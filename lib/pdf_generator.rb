class PdfGenerator
  attr_accessor :total_count, :api_url

  def initialize(ui_hash)
    @total_count = ui_hash[:total_count].to_i
    @api_url = ui_hash[:api_url]
    @ui_hash = ui_hash
    @pdf_report_id = ui_hash[:pdf_report_id]
  end

  def generate_pdf
    token = 'b26njx_9gj_dt9cz7jd4kpymgcq8anydqwjxw7'
    n = find_iteration
    1.times do |n|
      destination_path = create_temp_folder(n)
      offset = (n - 1) * 24
      api_url_with_limit = api_url + "&options=num-24.nosort.skp-#{offset}"
      response = RestClient.post api_url_with_limit + '&usertoken=' + token , :content_type => :xml
  		doc = Nokogiri::XML.parse(response)
      qr_codes = doc.xpath("/qdbapi/record")
      ac = ActionController::Base.new()
      html = ''
      html << ac.render_to_string(partial: 'layouts/css_styles')
      html << ac.render_to_string(
              partial: '/qr_codes/qr_codes_partial', locals: { qr_codes: qr_codes })
      File.open("#{destination_path}/file.html", 'w') { |file| file.write(html)}
      system(
      "wkhtmltopdf --print-media-type -T 0 -B 0 -L 0 -R 0 -O Landscape -s A4 #{destination_path}/file.html \
      #{destination_path}/file#{n}.pdf")
    end
    # combine_pdf_files(destination_path)
  end

  private

  def combine_pdf_files(path)
    system("pdftk #{destination_path}/*.pdf cat output #{destination_path}/final.pdf")
    pdf_report_obj = QrCodePdfReport.find(@pdf_report_id)
    file = File.open("#{destination_path}/final.pdf")
    pdf_report_obj.update_attributes(pdf_file: file, status: 'COMPLETED')
  end

  def create_temp_folder(num)
    @md5_hash = Digest::MD5.hexdigest(@ui_hash.values.to_s)
    FileUtils::mkdir_p "private/#{@md5_hash}"
    "private/#{@md5_hash}"
  end

  def find_iteration
    @total_count/24 + 1 if (@total_count % 24) > 0
  end
end
