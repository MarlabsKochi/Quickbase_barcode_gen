class QrCodesController < ApplicationController
		
	def index
		params[:page] ||= 1
		offset = (params[:page].to_i - 1) * 24
    api_url = "https://fedex.quickbase.com/db/bmbtc9fjh?a=API_DoQuery&query={158.XEX.'ePro is zero'}&options=num-24.nosort.skp-#{offset}"
    count_api_url = "https://fedex.quickbase.com/db/bmbtc9fjh?a=API_DoQueryCount&query={158.XEX.'ePro is zero'}"
		token = 'b26njx_9gj_dt9cz7jd4kpymgcq8anydqwjxw7'

		@response = RestClient.post api_url + '&usertoken=' + token , 
	            :content_type => :xml
	      response_count = RestClient.post count_api_url + '&usertoken=' + token , 
	            :content_type => :xml
    doc_count = Nokogiri::XML.parse(response_count)
    total_count = doc_count.xpath("/qdbapi").xpath('numMatches').children.text.to_i
    @total_pages = total_count/24 + 1 if (total_count % 24) > 0

		doc = Nokogiri::XML.parse(@response)

		@num = doc.xpath("/qdbapi/record")
		@kaminari_ary = Kaminari.paginate_array(@num).page(params[:page]).per(24)
		
		respond_to do |format|
      format.html
      format.pdf do
	    pdf = render_to_string :pdf => 'test',
	                     layout: 'application.html.erb',
	                     template: 'qr_codes/index.html.erb'
	    end
    end
	end

	def export_to_pdf
		api_url = 'https://fedex.quickbase.com/db/bmbtc9fjh?a=API_DoQuery&query={158.EX.''}'
		token = 'b26njx_9gj_dt9cz7jd4kpymgcq8anydqwjxw7'
		@response = RestClient.post api_url + '&usertoken=' + token , :content_type => :xml
		doc = Nokogiri::XML.parse(@response)
		@num=doc.xpath("/qdbapi/record").first(100)
		respond_to do |format|
      format.html
      format.pdf do
        pdf = Prawn::Document.new
        send_data pdf.render, filename: 'report_pdf.pdf', type: 'application/pdf'
      end
    end
	end
	
end
