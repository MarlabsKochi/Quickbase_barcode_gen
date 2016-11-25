class QrCodesController < ApplicationController

	def index
		params[:page] ||= 1
		offset = (params[:page].to_i - 1) * 24
    api_url = "https://fedex.quickbase.com/db/bmbtc9fjh?a=API_DoQuery&query={6.lt.'100'}"
		api_url_with_limit = api_url + "&options=num-24.nosort.skp-#{offset}"
    count_api_url = "https://fedex.quickbase.com/db/bmbtc9fjh?a=API_DoQueryCount&query={6.lt.'100'}"
		token = 'b26njx_9gj_dt9cz7jd4kpymgcq8anydqwjxw7'
		@response = RestClient.post api_url_with_limit + '&usertoken=' + token ,
	            :content_type => :xml
	      response_count = RestClient.post count_api_url + '&usertoken=' + token ,
	            :content_type => :xml
    doc_count = Nokogiri::XML.parse(response_count)
    @total_count = doc_count.xpath("/qdbapi").xpath('numMatches').children.text.to_i
    @total_pages = @total_count/24 + 1 if (@total_count % 24) > 0
		doc = Nokogiri::XML.parse(@response)
		@qr_codes = doc.xpath("/qdbapi/record")
		@kaminari_ary = Kaminari.paginate_array(@qr_codes).page(params[:page]).per(24)
	end

	def export_to_pdf
		api_url = "https://fedex.quickbase.com/db/bmbtc9fjh?a=API_DoQuery&query={6.lt.'100'}"
		pdf_report_record = find_pdf_report_record(api_url)
		if pdf_report_record.status == QrCodePdfReport::COMPLETED
			@url = download_report_qr_codes_path(id: pdf_report_record.id)
			render_path = 'qr_codes/download_report.js.erb'
		else
			PdfGenerator.new(total_count: params[:total_count], api_url: api_url,
										pdf_report_id: pdf_report_record.id).generate_pdf
			render_path = 'qr_codes/export_to_pdf.js.erb'
		end
		respond_to do |format|
			format.js { render render_path}
		end
	end

	def download_report
		pdf_report = QrCodePdfReport.find(params[:id])
		send_file pdf_report.pdf_file.path, :type => pdf_report.pdf_file_content_type, :disposition => 'inline'
	end

	private

	def find_pdf_report_record(api_url)
		report_obj = QrCodePdfReport.where(total_count: params[:total_count], api_url: api_url,
													status: QrCodePdfReport::COMPLETED).first
		if report_obj
			report_obj
		else
			QrCodePdfReport.create(total_count: params[:total_count], api_url: api_url,
														status: QrCodePdfReport::PENDING)
		end
	end

end
