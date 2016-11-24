class AddPdfFileColumnsToQrCodePdfReports < ActiveRecord::Migration
  def up
    add_attachment :qr_code_pdf_reports, :pdf_file
  end

  def down
    remove_attachment :qr_code_pdf_reports, :pdf_file
  end
end
