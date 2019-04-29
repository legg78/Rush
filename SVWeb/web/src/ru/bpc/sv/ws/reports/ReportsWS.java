package ru.bpc.sv.ws.reports;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.ws.soap.MTOM;
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
import ru.bpc.sv.reportsws.*;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.WebServiceConstants;
import ru.bpc.sv2.constants.reports.ReportConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.io.ByteArrayDataSource;
import ru.bpc.sv2.logic.ReportsDao;
import ru.bpc.sv2.reports.*;
import ru.bpc.sv2.scheduler.process.converter.JasperReportOutFileConverter;
import ru.bpc.sv2.ui.utils.XsltConverter;
import util.auxil.SessionWrapper;

import javax.activation.DataHandler;
import javax.annotation.Resource;
import javax.faces.context.FacesContext;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;
import javax.servlet.ServletContext;
import javax.xml.bind.annotation.XmlSeeAlso;
import javax.xml.ws.WebServiceContext;
import javax.xml.ws.handler.MessageContext;
import java.io.*;
import java.lang.reflect.Field;
import java.util.*;

@MTOM(enabled = true, threshold = 0)
@WebService(name = "ReportsWS", portName = "ReportsSOAP", serviceName = "Reports", targetNamespace = "http://bpc.ru/sv/reportsWS/")
@XmlSeeAlso({ObjectFactory.class})
@SOAPBinding(parameterStyle = SOAPBinding.ParameterStyle.BARE)
public class ReportsWS implements Reports {
    private static final Logger logger = Logger.getLogger("REPORTS");
    private static final Logger loggerDB = Logger.getLogger("REPORTS_DB");
    private static final String REPORT_DAO_NAME = "Reports";
    private static final Integer REPORT_ID = 10000010;
    private static final Integer TEMPLATE_ID = 10000002;
    private static final String SUCCESS = "SUCCESS";
    private static final String ERROR = "ERROR";
    private static final String INVOICE_ID = "I_INVOICE_ID";

    private ReportsDao reportDao;
    private String userName;
    private String userLanguage;
    private String imagePath;

    @Resource
    private WebServiceContext wsContext;

    @Override
    public MonthlyCreditCardStatementResponseType monthlyCreditCardStatement(MonthlyCreditCardStatementRequestType request) throws ReportsException {
        MonthlyCreditCardStatementResponseType response = new MonthlyCreditCardStatementResponseType();
        try {
            String cardNumber = null;
            Date effectiveDate = new Date();
            String format = ReportConstants.REPORT_FORMAT_TEXT;

            if (request.getCardNumber() != null && !request.getCardNumber().trim().isEmpty()) {
                cardNumber = request.getCardNumber().trim().replaceAll("[*]", "%").replaceAll("[?]", "_").toUpperCase();
            } else {
                throw new ReportsException("Required card number is absent");
            }
            if (request.getEffectiveDate() != null) {
                effectiveDate = request.getEffectiveDate().toGregorianCalendar().getTime();
            }
            if (request.getOutputFormat() != null && request.getOutputFormat().value() != null) {
                format = request.getOutputFormat().value();
            }

            initDao();
            ReportResult report = getReport(cardNumber, effectiveDate);
            if (report != null) {
                executeReport(report, format, cardNumber, response);
            } else {
                response.setResponseCode(ERROR);
                response.setResponseMessage("Report template is missed or invalid");
            }
        } catch (Exception e) {
            logger.trace(e.getMessage(), e);
            response.setResponseCode(ERROR);
            response.setResponseMessage(e.getMessage());
        }
        return response;
    }

    private void initDao() throws Exception {
        try {
            ServletContext servletContext = (ServletContext) wsContext.getMessageContext().get(MessageContext.SERVLET_CONTEXT);
            String userFile = servletContext.getInitParameter(SystemConstants.EXTERNAL_PROPERTIES_FILE);
            Properties prop = new Properties();
            prop.load(new FileInputStream(userFile));
            userName = prop.getProperty(WebServiceConstants.WS_USERNAME_PROPERTY);
            userName = (userName == null) ? WebServiceConstants.WS_DEFAULT_CREDENTIALS : userName;
        } catch (FileNotFoundException e) {
            logger.trace("Using default credentials...");
            userName = WebServiceConstants.WS_DEFAULT_CREDENTIALS;
        }

        userLanguage = SessionWrapper.getField("language");
        userLanguage = (userLanguage == null) ? SystemConstants.ENGLISH_LANGUAGE : userLanguage;

        reportDao = new ReportsDao();

        if (System.getProperty("os.name") != null && System.getProperty("os.name").contains("SunOS")) {
            Field headlessField = java.awt.GraphicsEnvironment.class.getDeclaredField("headless");
            headlessField.setAccessible(true);
            headlessField.set(null, Boolean.TRUE);
        }

        try {
            imagePath = FacesContext.getCurrentInstance().getExternalContext().getRequestContextPath() + "/image?image=";
        } catch (Exception e) {
            imagePath = "/image?image=";
        }
    }

    private ReportParameter[] getReportParameters(Long invoiceId) throws Exception {
        List<Filter> filters = new ArrayList<Filter>();
        filters.add(createFilter("reportId", REPORT_ID.toString()));
        filters.add(createFilter("lang", userLanguage));

        SelectionParams params = new SelectionParams();
        params.setFilters(filters.toArray(new Filter[filters.size()]));
        ReportParameter[] out = reportDao.getReportParameters(params);
        for (int i=0; i<out.length; i++) {
            if (out[i].getSystemName().equalsIgnoreCase(INVOICE_ID)) {
                out[i].setValueN(invoiceId.intValue());
            }
        }
        return out;
    }

    private ReportResult getReport(String cardNumber, Date effectiveDate) throws ReportsException, Exception {
        Long id = reportDao.getInvoiceIdByCardAndDate(cardNumber, effectiveDate, userLanguage);
        if (id == null) {
            throw new ReportsException("There is no linked invoice with card number and date");
        }

        Report report = reportDao.getReport(REPORT_ID, userLanguage);
        if (report == null) {
            throw new ReportsException("Failed to find report");
        }
        ReportResult result = reportDao.runReport(report, TEMPLATE_ID, getReportParameters(id));
        return result;
    }

    private Filter createFilter(String name, Object value) throws Exception {
        Filter filter = new Filter();
        filter.setElement(name);
        filter.setOp(Filter.Operator.eq);
        filter.setValue(value);
        return filter;
    }

    private void executeReport(ReportResult report, String format, String cardNumber,
                               MonthlyCreditCardStatementResponseType response) {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        try {
            if (report.getFileName() != null && !report.getFileName().trim().isEmpty()) {
                response.setFileName(report.getFileName().trim());
            } else {
                response.setFileName(getFileName(cardNumber, format));
            }

            if (report.getXmlFile() != null) {
                if (ReportConstants.TEMPLATE_PROCESSOR_JASPER.equals(report.getProcessor())) {
                    executeJasperReport(new FileInputStream(report.getXmlFile()), out, format);
                } else if (ReportConstants.TEMPLATE_PROCESSOR_XSLT.equals(report.getProcessor())) {
                    executeXsltReport(new FileInputStream(report.getXmlFile()), out);
                } else {
                    throw new ReportsException("Unsupported processor is configured for report");
                }
            } else if (report.getSqlData() != null) {
                executeSimpleReport(report.getSqlData(), out);
            } else {
                throw new ReportsException("Invalid data source for report");
            }

            response.setFileData(getDataHandlerFromBytes(out.toByteArray(), format));
            response.setResponseCode(SUCCESS);
            reportDao.setReportStatus(report.getRunId(), ReportConstants.REPORT_STATUS_GENERATED);
        }  catch (Exception e) {
            response.setResponseCode(ERROR);
            response.setResponseMessage(e.getMessage());
            reportDao.setReportStatus(report.getRunId(), ReportConstants.REPORT_STATUS_FAILED);
        } finally {
            IOUtils.closeQuietly(out);
        }
    }

    private void executeJasperReport(InputStream in, OutputStream out, String format) throws Exception {
        try {
            JasperReportOutFileConverter jasperConverter = new JasperReportOutFileConverter();
            jasperConverter.setHtmlReportImagePath(imagePath);
            jasperConverter.setInputStream(in);
            jasperConverter.setFileFormat(format);
            jasperConverter.setOutputStream(out);
            jasperConverter.convertFile();
            out.flush();
        } catch(Exception e) {
            throw new ReportsException(e.getMessage());
        } finally {
            IOUtils.closeQuietly(in);
        }
    }

    private void executeXsltReport(InputStream in, OutputStream out) throws Exception {
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        DocumentBuilder db = dbf.newDocumentBuilder();

        InputStreamReader isr = new InputStreamReader(in, SystemConstants.DEFAULT_CHARSET);
        Document doc = db.parse(new InputSource(isr));
        IOUtils.closeQuietly(isr);

        NodeList nodeList = doc.getElementsByTagName("datasource");
        Node dataSourceNode = nodeList.item(0);

        nodeList = doc.getElementsByTagName("template");
        Node templateNode = nodeList.item(0).getFirstChild();

        XsltConverter.convertFromNodes(templateNode, dataSourceNode, out, null);
    }

    private void executeSimpleReport(QueryResult data, OutputStream out) throws Exception {
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
        wb.write(out);
    }

    private DataHandler getDataHandlerFromBytes(byte[] data, String format) throws Exception {
        ByteArrayDataSource ds = null;
        if (ReportConstants.REPORT_FORMAT_PDF.equalsIgnoreCase(format)) {
            ds = new ByteArrayDataSource(data, "application/pdf");
        } else if (ReportConstants.REPORT_FORMAT_CSV.equalsIgnoreCase(format)) {
            ds = new ByteArrayDataSource(data, "text/csv");
        } else if (ReportConstants.REPORT_FORMAT_HTML.equalsIgnoreCase(format)) {
            ds = new ByteArrayDataSource(data, "application/xml");
        } else if (ReportConstants.REPORT_FORMAT_RTF.equalsIgnoreCase(format)) {
            ds = new ByteArrayDataSource(data, "application/msword");
        } else if (ReportConstants.REPORT_FORMAT_EXCEL.equalsIgnoreCase(format)) {
            ds = new ByteArrayDataSource(data, "application/vnd.ms-excel");
        } else if (ReportConstants.REPORT_FORMAT_TEXT.equalsIgnoreCase(format)) {
            ds = new ByteArrayDataSource(data, "text/plain");
        } else {
            ds = new ByteArrayDataSource(data, "application/octet-stream");
        }
        return new DataHandler(ds);
    }

    private String getFileName(String cardNumber, String format) {
        GregorianCalendar gc = new GregorianCalendar();
        StringBuilder name = new StringBuilder();

        name.append(cardNumber);
        name.append("_");
        name.append(gc.get(Calendar.YEAR));
        name.append((gc.get(Calendar.MONTH) + 1));
        name.append(gc.get(Calendar.DAY_OF_MONTH));
        name.append("_");
        name.append(gc.get(Calendar.HOUR));
        name.append(gc.get(Calendar.MINUTE));
        name.append(gc.get(Calendar.SECOND));
        name.append(".");

        if (ReportConstants.REPORT_FORMAT_PDF.equalsIgnoreCase(format)) {
            name.append("pdf");
        } else if (ReportConstants.REPORT_FORMAT_CSV.equalsIgnoreCase(format)) {
            name.append("csv");
        } else if (ReportConstants.REPORT_FORMAT_HTML.equalsIgnoreCase(format)) {
            name.append("xml");
        } else if (ReportConstants.REPORT_FORMAT_RTF.equalsIgnoreCase(format)) {
            name.append("doc");
        } else if (ReportConstants.REPORT_FORMAT_EXCEL.equalsIgnoreCase(format)) {
            name.append("xls");
        } else if (ReportConstants.REPORT_FORMAT_TEXT.equalsIgnoreCase(format)) {
            name.append("txt");
        } else {
            name.append("bin");
        }

        return name.toString();
    }
}
