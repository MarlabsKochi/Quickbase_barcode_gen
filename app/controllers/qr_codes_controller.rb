class QrCodesController < ApplicationController

	def index
		params[:page] ||= 1
		offset = (params[:page].to_i - 1) * 24
    api_url = "https://fedex.quickbase.com/db/bmbtc9fjh?a=API_DoQuery&query={158.XEX.'ePro is zero'}"
		api_url_with_limit = api_url + "&options=num-24.nosort.skp-#{offset}"
    count_api_url = "https://fedex.quickbase.com/db/bmbtc9fjh?a=API_DoQueryCount&query={158.XEX.'ePro is zero'}"
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
		api_url = "https://fedex.quickbase.com/db/bmbtc9fjh?a=API_DoQuery&query={158.XEX.'ePro is zero'}"
		pdf_report_record = find_pdf_report_record(api_url)
		if pdf_report_record.present?
			@url = pdf_report_record.path
			render_path = 'qr_codes/download_report.js.erb'
		else
			PdfGenerator.new(total_count: params[:total_count], api_url: api_url).generate_pdf
			render_path = 'qr_codes/export_to_pdf.js.erb'
		end
	end

	private

	def find_pdf_report_record(api_url)
		QrCodePdfReport.where(total_count: params[:total_count], api_url: api_url)
	end

end
