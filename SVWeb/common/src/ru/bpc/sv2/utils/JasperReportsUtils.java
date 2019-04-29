package ru.bpc.sv2.utils;

import net.sf.jasperreports.engine.*;
import net.sf.jasperreports.engine.export.*;
import net.sf.jasperreports.engine.export.ooxml.JRXlsxExporter;
import net.sf.jasperreports.engine.fill.JRSwapFileVirtualizer;
import net.sf.jasperreports.engine.query.JRXPathQueryExecuterFactory;
import net.sf.jasperreports.engine.util.JRLoader;
import net.sf.jasperreports.engine.util.JRSwapFile;
import ru.bpc.sv2.constants.reports.ReportConstants;

import java.io.InputStream;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.Map;

public class JasperReportsUtils {
	public static void execute(InputStream datasourceInputStream,
							   InputStream templateInputStream,
	                           OutputStream outputStream,
							   String fileFormat,
							   String htmlReportImagePath,
							   String pdfPassword) throws Exception {
		DefaultJasperReportsContext context = DefaultJasperReportsContext.getInstance();
		JRPropertiesUtil.getInstance(context).setProperty("net.sf.jasperreports.xpath.executer.factory",
				"net.sf.jasperreports.engine.util.xml.JaxenXPathExecuterFactory");

		Map<String, Object> param = new HashMap<String, Object>();
		param.put(JRXPathQueryExecuterFactory.XML_INPUT_STREAM, datasourceInputStream);
		param.put(JRXPathQueryExecuterFactory.XML_DATE_PATTERN, "yyyy-MM-dd");
		JRSwapFile swap = new JRSwapFile(SystemUtils.getTempDirPath(), 1024, 1024);
		JRSwapFileVirtualizer virtualizer = new JRSwapFileVirtualizer(5, swap, true);
		param.put(JRParameter.REPORT_VIRTUALIZER, virtualizer);

		try {
		JasperReport jasperReport = (JasperReport) JRLoader.loadObject(templateInputStream);
		JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, param);

		if (ReportConstants.REPORT_FORMAT_HTML.equals(fileFormat)) {
			JRHtmlExporter htmlExporter = new JRHtmlExporter();
			htmlExporter.setParameter(JRExporterParameter.JASPER_PRINT, jasperPrint);
			htmlExporter.setParameter(JRExporterParameter.OUTPUT_STREAM, outputStream);
			if (htmlReportImagePath != null) {
				htmlExporter.setParameter(JRHtmlExporterParameter.IMAGES_URI, htmlReportImagePath);
			} else {
				htmlExporter.setParameter(JRHtmlExporterParameter.IS_USING_IMAGES_TO_ALIGN, false);
			}
			htmlExporter.exportReport();
		} else if (ReportConstants.REPORT_FORMAT_TEXT.equals(fileFormat)) {
			JRTextExporter textExporter = new JRTextExporter();
			textExporter.setParameter(JRExporterParameter.JASPER_PRINT, jasperPrint);
			textExporter.setParameter(JRExporterParameter.OUTPUT_STREAM, outputStream);
			Integer pageHeight = jasperPrint.getPageHeight() > 0 ? Math.round(jasperPrint.getPageHeight() / 10) : 90;
			Integer pageWidth = jasperPrint.getPageWidth() > 0 ? Math.round(jasperPrint.getPageWidth() / 10) : 120;
			textExporter.setParameter(JRTextExporterParameter.CHARACTER_HEIGHT, new Float(10));
			textExporter.setParameter(JRTextExporterParameter.CHARACTER_WIDTH, new Float(10));
			textExporter.setParameter(JRTextExporterParameter.PAGE_WIDTH, pageWidth);
			textExporter.setParameter(JRTextExporterParameter.PAGE_HEIGHT, pageHeight);
			textExporter.exportReport();
		} else if (ReportConstants.REPORT_FORMAT_EXCEL.equals(fileFormat)) {
			JRXlsxExporter xlsExporter = new JRXlsxExporter();
			xlsExporter.setParameter(JRXlsExporterParameter.JASPER_PRINT, jasperPrint);
			xlsExporter.setParameter(JRXlsExporterParameter.OUTPUT_STREAM, outputStream);
			//xlsExporter.setParameter(JRXlsExporterParameter.IS_ONE_PAGE_PER_SHEET, Boolean.FALSE);
			//xlsExporter.setParameter(JRXlsExporterParameter.IS_DETECT_CELL_TYPE, Boolean.TRUE);
			xlsExporter.setParameter(JRXlsExporterParameter.IS_WHITE_PAGE_BACKGROUND, Boolean.FALSE);
			//xlsExporter.setParameter(JRXlsExporterParameter.IS_REMOVE_EMPTY_SPACE_BETWEEN_ROWS, Boolean.TRUE);
			xlsExporter.exportReport();
		} else if (ReportConstants.REPORT_FORMAT_RTF.equals(fileFormat)) {
			JRRtfExporter rtfExporter = new JRRtfExporter();
			rtfExporter.setParameter(JRExporterParameter.JASPER_PRINT, jasperPrint);
			rtfExporter.setParameter(JRExporterParameter.OUTPUT_STREAM, outputStream);
			rtfExporter.exportReport();
		} else if (ReportConstants.REPORT_FORMAT_CSV.equals(fileFormat)) {
			JRCsvExporter csvExporter = new JRCsvExporter();
			csvExporter.setParameter(JRExporterParameter.JASPER_PRINT, jasperPrint);
			csvExporter.setParameter(JRExporterParameter.OUTPUT_STREAM, outputStream);
			csvExporter.exportReport();
		} else {
			if (pdfPassword != null && !pdfPassword.isEmpty()) {
				JRPdfExporter pdfExporter = new JRPdfExporter();
				pdfExporter.setParameter(JRExporterParameter.JASPER_PRINT, jasperPrint);
				pdfExporter.setParameter(JRExporterParameter.OUTPUT_STREAM, outputStream);
				pdfExporter.setParameter(JRPdfExporterParameter.IS_ENCRYPTED, Boolean.TRUE);
				pdfExporter.setParameter(JRPdfExporterParameter.USER_PASSWORD, pdfPassword);
				pdfExporter.exportReport();
			} else {
				JasperExportManager.exportReportToPdfStream(jasperPrint, outputStream);
			}
		}
		datasourceInputStream.close();
		templateInputStream.close();
		} finally {
			try {
				virtualizer.cleanup();
			} catch (Exception ignored) {
	}
		}
	}

	public static void execute(InputStream datasourceInputStream, InputStream templateInputStream, OutputStream outputStream) throws Exception {
		execute(datasourceInputStream, templateInputStream, outputStream, ReportConstants.REPORT_FORMAT_PDF, null);
	}

	public static void execute(InputStream datasourceInputStream, InputStream templateInputStream, OutputStream outputStream, String fileFormat) throws Exception {
		execute(datasourceInputStream, templateInputStream, outputStream, fileFormat, null);
	}

	public static void execute(InputStream datasourceInputStream, InputStream templateInputStream,
							   OutputStream outputStream, String fileFormat, String htmlReportImagePath) throws Exception {
		execute(datasourceInputStream, templateInputStream, outputStream, fileFormat, htmlReportImagePath, null);
	}
}
