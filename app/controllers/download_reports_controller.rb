class DownloadReportsController < ApplicationController

  def index
    @pdf_reports = QrCodePdfReport.all
  end
end
