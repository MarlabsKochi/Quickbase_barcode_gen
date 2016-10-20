class QrCodesController < ApplicationController
	require "rest-client"
    require "nokogiri"
	def index
	# response = RestClient.post 'https://marlabsdev.quickbase.com/db/bkuuwumss?a=API_GetRecordInfo&rid=1
	# &ticket=8_bkuxg37xp_b2t8td_h6jf_a_dshpzw9c8ycs67c9jy7nqdi8sqkatta335dsrkse6ck34ckjbvzs4u&apptoken=dfaa2irct2yuxm2cep65c9c3am3', :content_type => :xml 
	# doc = Nokogiri::XML.parse(response)
	# src = doc.xpath("//value").first.children.text
	api_url = 'https://marlabsdev.quickbase.com/db/bkuuwumss?a=API_GetNumRecords'
	ticket = '8_bk9tsmqnw_b24dps_h6jf_a_cqmxsgidc2h6gcdhpxpm92zzwd5ctiv7eacgc3k95b2etiezrt6yt8'
	token = 'dfaa2irct2yuxm2cep65c9c3am3'
	response = RestClient.post api_url + '&ticket=' + ticket + '&apptoken=' + token, 
	            :content_type => :xml 
	doc = Nokogiri::XML.parse(response)
	@num = doc.xpath("//num_records").children.text.to_i
	#   pdf = WickedPdf.new.pdf_from_string(
 #                        render_to_string(
 #                          template: '/qr_codes/index.pdf.erb'))
 #  send_data(pdf,
 #            filename: 'file_name.pdf',
 #            type: 'application/pdf',
 #            disposition: 'attachment')
#render :pdf => 'index'
	end
end
