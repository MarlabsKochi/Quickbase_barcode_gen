class CreateQrCodePdfReports < ActiveRecord::Migration
  def change
    create_table :qr_code_pdf_reports do |t|
      t.integer :total_count
      t.string :api_url
      t.string :status

      t.timestamps null: false
    end
  end
end
