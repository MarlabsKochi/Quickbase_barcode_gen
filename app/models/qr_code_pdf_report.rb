class QrCodePdfReport < ActiveRecord::Base
  has_attached_file :pdf_file
  validates_attachment_content_type :pdf_file,
    content_type: ['application/pdf'],
    url: "/controllers/:style/:basename.:extension",
    path: ":rails_root/private/pdf_report/:basename.:extension"
end
