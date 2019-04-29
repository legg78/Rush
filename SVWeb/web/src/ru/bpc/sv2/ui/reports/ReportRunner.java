package ru.bpc.sv2.ui.reports;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import org.apache.log4j.Logger;
import org.apache.poi.hssf.usermodel.HSSFRichTextString;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.reports.ReportConstants;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.logic.ReportsDao;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.reports.QueryResult;
import ru.bpc.sv2.reports.Report;
import ru.bpc.sv2.reports.ReportParameter;
import ru.bpc.sv2.reports.ReportResult;
import ru.bpc.sv2.scheduler.process.converter.JasperReportOutFileConverter;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.RequestContextHolder;
import ru.bpc.sv2.ui.utils.XsltConverter;
import ru.bpc.sv2.utils.SystemUtils;
import ru.bpc.sv2.utils.Transliteration;
import util.servlet.FileServlet;

import javax.faces.context.FacesContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.*;
import java.net.URLEncoder;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.Map;

public class ReportRunner implements Serializable {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("REPORTS");

	private ReportsDao reportsDao;

	private String reportFormat;

	private String filename;
	private File outFile;

	private Long userSessionId;

	public ReportRunner(Long userSessionId) {
		this.userSessionId = userSessionId;
		reportsDao = new ReportsDao();
	}


	private void executeJasperReport(File xml, OutputStream out, String savePath) throws Exception {
		InputStream inputStream = null;
		try {
			if (xml == null) {
				throw new RuntimeException(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Rpt", "report_empty"));
			}
			inputStream = new FileInputStream(xml);

			JasperReportOutFileConverter jasperConverter = new JasperReportOutFileConverter();
			jasperConverter.setInputStream(inputStream);
			jasperConverter.setFileFormat(reportFormat);
			jasperConverter.setHtmlReportImagePath(FacesContext.getCurrentInstance()
					.getExternalContext().getRequestContextPath() + "/image?image=");

			if (savePath == null) {
				jasperConverter.setOutputStream(out);
				jasperConverter.convertFile();
			} else {
				FileOutputStream fos = new FileOutputStream(savePath);
				jasperConverter.setOutputStream(fos);
				jasperConverter.convertFile();
				IOUtils.closeQuietly(fos);

				FileInputStream in = new FileInputStream(savePath);
				IOUtils.copy(in, out);
				IOUtils.closeQuietly(in);
			}
		} finally {
			IOUtils.closeQuietly(inputStream);
		}
	}

	public String getFilename(String extension) {
		GregorianCalendar gc = new GregorianCalendar();

		return "" + gc.get(Calendar.YEAR) + (gc.get(Calendar.MONTH) + 1)
				+ gc.get(Calendar.DAY_OF_MONTH) + "." + extension;
	}

	private void executeSimpleReport(QueryResult data, OutputStream out, String savePath) throws Exception {
		HSSFWorkbook wb = new HSSFWorkbook();
		HSSFSheet sheet = wb.createSheet("Data");
		int i = 0, j = 0;
		HSSFRow row = sheet.createRow(i++);
		for (String columnName : data.getFieldNames()) {
			row.createCell(j++).setCellValue(new HSSFRichTextString(columnName));
		}
		j = 0;
		for (HashMap<String, String> map : data.getFields()) {
			row = sheet.createRow(i++);
			for (String columnName : data.getFieldNames()) {
				row.createCell(j++).setCellValue(new HSSFRichTextString(map.get(columnName)));
			}
			j = 0;
		}

		FileOutputStream fos = null;
		try {
			if (savePath != null) {
				fos = new FileOutputStream(savePath);
				wb.write(fos);
			}
			wb.write(out);
		} finally {
			if (fos != null) {
				fos.close();
			}
		}
	}

	public void runReport(Report report, String reportFormat, ReportParameter[] reportParameters,
	                      Integer templateId) throws Exception {
		filename = null;
		Long runId = null;
		try {
			this.reportFormat = reportFormat;
			QueryResult data;

			logger.trace("Running report ID = " + report.getId());
			ReportResult reportResult = reportsDao.runReport(userSessionId, report, templateId, reportParameters);
			runId = reportResult.getRunId();
			logger.trace("Got report ID = " + report.getId() + "; run ID = " + runId);
			logger.trace("Run ID = " + runId + "; Source type = " + report.getSourceType());
			logger.trace("Run ID = " + runId + "; Is deterministic = " + reportResult.isDeterministic());
			logger.trace("Run ID = " + runId + "; Is already saved = " + reportResult.isAlreadySaved());
			logger.trace("Run ID = " + runId + "; File name = " + reportResult.getFileName());
			logger.trace("Run ID = " + runId + "; Save path = " + reportResult.getSavePath());
			logger.trace("Run ID = " + runId + "; XML data = " + (reportResult.getXmlFile() != null ? reportResult.getXmlFile().getAbsolutePath() : null));
			logger.trace("Run ID = " + runId + "; SQL data = " + reportResult.getSqlData());
			logger.trace("Run ID = " + runId + "; Processor = " + reportResult.getProcessor());

			outFile = SystemUtils.getTempFile("report");
			OutputStream outStream = new FileOutputStream(outFile);
			String extension = null;
			boolean alreadySaved = reportResult.isAlreadySaved();

			Transliteration trs = new Transliteration();
			if (reportResult.getFileName() != null) {
				filename = trs.transliterate(reportResult.getFileName());
			}

			if (alreadySaved) {
				getGeneratedReport(reportResult.getSavePath(), outStream);
				if (ReportConstants.REPORT_SOURCE_TYPE_SIMPLE.equals(report.getSourceType())) {
					extension = "xls";
				} else {
					extension = getExtension(reportFormat);
				}
			} else {
				String savePath = null;
				if (reportResult.isDeterministic()) {
					savePath = reportResult.getSavePath();
					if (savePath == null) {
						throw new IOException(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Rpt",
								ReportConstants.SAVE_PATH_EMPTY_FOR_DTRMN_RPT));
					}
				}
				if (ReportConstants.REPORT_SOURCE_TYPE_SIMPLE.equals(report.getSourceType())) {
					data = reportResult.getSqlData();
					executeSimpleReport(data, outStream, savePath);
					reportFormat = null;
					extension = "xls";
				}
				if (ReportConstants.REPORT_SOURCE_TYPE_XML.equals(report.getSourceType())) {
					extension = getExtension(reportFormat);
					if (ReportConstants.TEMPLATE_PROCESSOR_JASPER.equals(reportResult.getProcessor())) {
						executeJasperReport(reportResult.getXmlFile(), outStream, savePath);
					} else {
						executeXsltReport(reportResult.getXmlFile(), outStream, savePath);
					}
				}
			}

			IOUtils.closeQuietly(outStream);

			if (filename == null) {
				filename = getFilename(extension);
				filename = trs.transliterate(report.getName()).replaceAll(" ", "_") + "_" + filename;
			}

			reportsDao.setReportStatus(userSessionId, runId, ReportConstants.REPORT_STATUS_GENERATED);
		} catch (Exception e) {
			if (runId != null) {
				try {
					reportsDao.setReportStatus(userSessionId, runId,
							ReportConstants.REPORT_STATUS_FAILED);
				} catch (Exception e1) {
					logger.error("", e1);
				}
			}
			throw e;
		}
	}

	public void runReportToFile(Report report, String reportFormat, ReportParameter[] reportParameters,
	                            Integer templateId, Integer containerId, Long sessionId) throws Exception {
		Long runId = null;

		try {
			this.reportFormat = reportFormat;
			logger.trace("Running report ID = " + report.getId() + " to file");
			ReportResult reportResult = reportsDao.runReport(userSessionId, report, templateId, reportParameters);
			runId = reportResult.getRunId();
			logger.trace("Got report ID = " + report.getId() + "; run ID = " + runId);
			logger.trace("Run ID = " + runId + "; Source type = " + report.getSourceType());
			logger.trace("Run ID = " + runId + "; Is deterministic = " + reportResult.isDeterministic());
			logger.trace("Run ID = " + runId + "; Is already saved = " + reportResult.isAlreadySaved());
			logger.trace("Run ID = " + runId + "; File name = " + reportResult.getFileName());
			logger.trace("Run ID = " + runId + "; Save path = " + reportResult.getSavePath());
			logger.trace("Run ID = " + runId + "; XML data = " + (reportResult.getXmlFile() != null ? reportResult.getXmlFile().getAbsolutePath() : null));
			logger.trace("Run ID = " + runId + "; SQL data = " + reportResult.getSqlData());
			logger.trace("Run ID = " + runId + "; Processor = " + reportResult.getProcessor());

			boolean alreadySaved = reportResult.isAlreadySaved();
			if (!alreadySaved) {
				saveToFileReport(reportResult.getSavePath(), reportResult.getXmlFile());
			}
			String savePath = reportResult.getSavePath();
			regOpenFile(savePath, containerId, sessionId);
			reportsDao.setReportStatus(userSessionId, runId, ReportConstants.REPORT_STATUS_GENERATED);
		} catch (Exception e) {
			if (runId != null) {
				try {
					reportsDao.setReportStatus(userSessionId, runId, ReportConstants.REPORT_STATUS_FAILED);
				} catch (Exception e1) {
					logger.error("", e1);
				}
			}
			throw e;
		}
	}

	public void regOpenFile(String savePath, Integer containerId, Long sessionId) {
		filename = savePath.substring(savePath.lastIndexOf("/") + 1);
		ProcessFileAttribute pfa = new ProcessFileAttribute();
		pfa.setPurpose(ProcessConstants.FILE_PURPOSE_OUTGOING);
		pfa.setFileType(ProcessConstants.FILE_TYPE_REPORT);
		pfa.setFileName(filename);
		pfa.setContainerBindId(containerId);
		pfa.setSessionId(sessionId);
		try {
			ProcessDao _processDao = new ProcessDao();
			Long sess_file_id = _processDao.openFile(userSessionId, pfa);

			Map<String, Object> map = new HashMap<String, Object>();
			System.out.println("sess_file_id:" + sess_file_id);
			map.put("sessionFileId", sess_file_id);
			map.put("clob_content", savePath);
			map.put("add_to", false);
			_processDao.putFileClob(userSessionId, map);
		} catch (Exception e) {
			logger.error("", e);
		}
	}

	public void saveToFileReport(String savePath, File xml) throws IOException {
		if (savePath == null) {
			throw new IOException(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Rpt",
					ReportConstants.SAVE_PATH_EMPTY_FOR_DTRMN_RPT));
		}
		if (xml == null) {
			throw new RuntimeException(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Rpt", "report_empty"));
		}
		FileUtils.copyFile(xml, new File(savePath));
	}

	public void getGeneratedReport(String savePath, OutputStream outStream) throws IOException {
		if (savePath == null) {
			throw new IOException(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Rpt",
					ReportConstants.SAVE_PATH_EMPTY_FOR_DTRMN_RPT));
		}
		FileInputStream fis = null;
		try {
			fis = new FileInputStream(savePath);
			IOUtils.copy(fis, outStream);
		} finally {
			IOUtils.closeQuietly(fis);
		}
	}

	public void generateFile() throws Exception {
		if (outFile != null) {
			HttpServletResponse res = RequestContextHolder.getResponse();
			if (ReportConstants.REPORT_FORMAT_HTML.equals(reportFormat)) {
				res.setContentType("text/html");
			} else {
				res.setContentType("application/x-download");
				String URLEncodedFileName = URLEncoder.encode(filename, "UTF-8");
				res.setHeader("Content-Disposition", "attachment; filename=\"" + URLEncodedFileName + "\"");
			}
			SystemUtils.copy(outFile, res.getOutputStream());
			FacesContext.getCurrentInstance().responseComplete();
		}
	}

	private void executeXsltReport(File xml, OutputStream out, String savePath) throws Exception {
		if (xml == null) {
			throw new RuntimeException(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Rpt", "report_empty"));
		}
		DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
		DocumentBuilder db = dbf.newDocumentBuilder();

		InputStreamReader isr = new InputStreamReader(new FileInputStream(xml), SystemConstants.DEFAULT_CHARSET);
		Document doc = db.parse(new InputSource(isr));
		IOUtils.closeQuietly(isr);

		//getting datasource
		NodeList nodeList = doc.getElementsByTagName("datasource");
		Node dataSourceNode = nodeList.item(0);

		//getting template
		nodeList = doc.getElementsByTagName("template");
		Node templateNode = nodeList.item(0).getFirstChild();
		//doc = db.parse(new InputSource(new StringReader(templateNode.getTextContent())));

		XsltConverter.convertFromNodes(templateNode, dataSourceNode, out, savePath);
	}

	private String getExtension(String reportFormat) {
		String extension;
		if (ReportConstants.REPORT_FORMAT_HTML.equals(reportFormat)) {
			extension = "html";
		} else if (ReportConstants.REPORT_FORMAT_TEXT.equals(reportFormat)) {
			extension = "txt";
		} else if (ReportConstants.REPORT_FORMAT_EXCEL.equals(reportFormat)) {
			extension = "xlsx";
		} else if (ReportConstants.REPORT_FORMAT_RTF.equals(reportFormat)) {
			extension = "rtf";
		} else if (ReportConstants.REPORT_FORMAT_CSV.equals(reportFormat)) {
			extension = "csv";
		} else {
			extension = "pdf";
		}
		return extension;
	}

	public String getReportFormat() {
		return reportFormat;
	}

	@SuppressWarnings("UnusedDeclaration")
	public void setReportFormat(String reportFormat) {
		this.reportFormat = reportFormat;
	}

	public String getFilename() {
		return filename;
	}

	public void setFilename(String filename) {
		this.filename = filename;
	}

	public Long getUserSessionId() {
		return userSessionId;
	}

	public void setUserSessionId(Long userSessionId) {
		this.userSessionId = userSessionId;
	}

	public File getOutFile() {
		return outFile;
	}

	public void generateFileByServlet() {
		if (outFile == null) return;

		HttpServletRequest req = RequestContextHolder.getRequest();
		HttpSession session = req.getSession();
		if (ReportConstants.REPORT_FORMAT_HTML.equals(reportFormat)) {
			session.setAttribute(FileServlet.FILE_SERVLET_CONTENT_TYPE, "text/html");
		} else {
			session.setAttribute(FileServlet.FILE_SERVLET_CONTENT_TYPE, "application/x-download");
		}
		session.setAttribute(FileServlet.FILE_SERVLET_FILE_PATH, outFile.getAbsolutePath());
	}
}
