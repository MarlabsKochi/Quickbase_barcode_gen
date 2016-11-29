module DownloadReportsHelper

  def display_file_name(report)
    if report.status == QrCodePdfReport::COMPLETED
      report.pdf_file_file_name
    else
      ''
    end
  end

  def display_file_type(report)
    if report.status == QrCodePdfReport::COMPLETED
      report.pdf_file_content_type
    else
      ''
    end
  end
end
