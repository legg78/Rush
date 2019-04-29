package ru.bpc.sv2.ui.reports.constructor.web;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;

import net.sf.dynamicreports.report.builder.datatype.DateType;
import org.apache.log4j.Logger;

import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.UsersDao;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.ui.reports.constructor.support.MbReportTemplateSupport;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.utils.Transliteration;
import ru.jtsoft.dynamicreports.ReportingDataModel;
import ru.jtsoft.dynamicreports.exceptions.ReportException;
import ru.jtsoft.dynamicreports.model.DictionaryValue;
import ru.jtsoft.dynamicreports.model.Parameter;
import ru.jtsoft.dynamicreports.model.types.Type;
import ru.jtsoft.dynamicreports.report.BetweenConditionExpressionNode;
import ru.jtsoft.dynamicreports.report.ExportReportContext;
import ru.jtsoft.dynamicreports.report.ExpressionNode;
import ru.jtsoft.dynamicreports.report.ExpressionNodeList;
import ru.jtsoft.dynamicreports.report.InConditionExpressionNode;
import ru.jtsoft.dynamicreports.report.LogicalConditionExpressionNode;
import ru.jtsoft.dynamicreports.report.LogicalConditionType;
import ru.jtsoft.dynamicreports.report.OperatorType;
import ru.jtsoft.dynamicreports.report.Report;
import ru.jtsoft.dynamicreports.report.ReportTemplate;
import ru.jtsoft.dynamicreports.report.UnaryConditionExpressionNode;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

@ManagedBean(name = "MbExportReport")
@ViewScoped
public final class MbExportReport extends MbReportTemplateSupport implements Serializable {

    private static final long serialVersionUID = -4571612424158831123L;
    private static final String TILL_ID_EXPRESSION_PREFIX = "com_api_id_pkg.get_till_id(";
    private static final String FROM_ID_EXPRESSION_PREFIX = "com_api_id_pkg.get_from_id(";
    private static final String TO_DATE_EXPRESSION_PREFIX = "to_date('";
    private static final String TO_DATE_EXPRESSION_POSTFIX = "', 'YYYY-MM-DD')";
    private static final String ID_EXPRESSION_POSTFIX = ")";

    private static final String ENCODING = "UTF-8";
    private static Logger logger = Logger.getLogger("DYNAMIC_REPORT");
    private List<ReportFormat> reportFormatList;
    private ReportFormat reportFormat;
    private UsersDao _usersDao = new UsersDao();

    private transient Report report;


    private String name;

    private int rowCount;
    private int firstRow;
    private int endRow;
    private int scrollerPage = 1;

    private int rowsNum = 20;
    private ByteArrayOutputStream exportResult = new ByteArrayOutputStream();

    public ByteArrayOutputStream getExportResult() {
        return exportResult;
    }

    public void setExportResult(ByteArrayOutputStream exportResult) {
        this.exportResult = exportResult;
    }

    public int getRowCount() {
        return rowCount;
    }


    public int getMaxCount() {
        return getEnvironment().getMaxReportRecords();
    }

    private Map<String, DictionaryValue> paramValueMap = new HashMap<String, DictionaryValue>();

    @Override
    protected void initReportTemplate(Long reportTemplateId) {

        if (reportTemplateId == null) {
            return;
        }
        exportResult = new ByteArrayOutputStream();

        ReportTemplate reportTemplate = getReportTemplateDao()
                .getReportTemplateById(reportTemplateId);

        refactorTemplate(reportTemplate);

        try {
            report = new Report(reportTemplate, getEnvironment());
        } catch (Exception e) {
            addErrorMessage("datasource_error");
        }

        name = reportTemplate.getName();
    }

    public String back() {
        return "list_report_templates";
    }

    private void refactorTemplate(ReportTemplate reportTemplate) {
        addInstCondition(reportTemplate);
        paramValueMap = new HashMap<String, DictionaryValue>();
        ReportingDataModel reportingDataModel = getEnvironment().getReportingDataModel();
        Parameter param = reportingDataModel.getParameterById("HOST_DATE");
        Type<DateType> type = (Type<DateType>) param.getType();
        paramValueMap = type.getDictionary();
        replaceHostDate(reportTemplate.getConditions());
    }

    private void addInstCondition(ReportTemplate reportTemplate) {

        List<ExpressionNode> nodeList = reportTemplate.getConditions().getChildNodes();
        UserSession us = (UserSession) ManagedBeanWrapper.getManagedBean("usession");
        List<String> instIdList = new ArrayList<String>();
        instIdList.add(String.valueOf(us.getUserInst()));

        try {
            Long userSessionId = Long.parseLong(SessionWrapper.getField("userSessionId"));

            SelectionParams params = new SelectionParams(Arrays.asList(
                    new Filter("userId", us.getUser().getId())));
            Institution[] institutions = _usersDao.getInstitutionsForUser(userSessionId, params);
            for (Institution item : institutions) {
                instIdList.add(String.valueOf(item.getId()));
            }
        } catch (Exception e) {
            logger.debug(e);
        }

        nodeList.add(new LogicalConditionExpressionNode(LogicalConditionType.AND));
        nodeList.add(new InConditionExpressionNode("INST_ID", OperatorType.IN, instIdList));

    }

    private void replaceHostDate(ExpressionNodeList nodeList) {

        ListIterator<ExpressionNode> iterator = nodeList.getChildNodes().listIterator();

        while (iterator.hasNext()) {
            ExpressionNode node = iterator.next();
            if (node instanceof UnaryConditionExpressionNode) {
                UnaryConditionExpressionNode condNode = (UnaryConditionExpressionNode) node;
                if (condNode.getParameterId().equals("HOST_DATE")) {
                    String value = condNode.getValue();
                    if (paramValueMap.get(value) != null) {
                        value = paramValueMap.get(value).getValue();
                    } else {
                        value = TO_DATE_EXPRESSION_PREFIX + value + TO_DATE_EXPRESSION_POSTFIX;
                    }

                    UnaryConditionExpressionNode newNode = null;
                    if (condNode.getOperator().equals(OperatorType.GREATER_THAN) ||
                            condNode.getOperator().equals(OperatorType.STRICTLY_GREATER_THAN)) {

                        newNode = new UnaryConditionExpressionNode("OPERATION_ID", condNode.getOperator(),
                                FROM_ID_EXPRESSION_PREFIX + value + ID_EXPRESSION_POSTFIX);
                    } else if (condNode.getOperator().equals(OperatorType.STRICTLY_LESS) ||
                            condNode.getOperator().equals(OperatorType.STRICTLY_LESS_THAN)) {
                        newNode = new UnaryConditionExpressionNode("OPERATION_ID", condNode.getOperator(),
                                TILL_ID_EXPRESSION_PREFIX + value + ID_EXPRESSION_POSTFIX);

                    }
                    if (newNode != null) {
                        iterator.remove();
                        iterator.add(newNode);
                    }
                }
            }
            if (node instanceof BetweenConditionExpressionNode) {
                BetweenConditionExpressionNode condNode = (BetweenConditionExpressionNode) node;


                if (condNode.getParameterId().equals("HOST_DATE")) {
                    String leftValue = condNode.getValueLeft();
                    if (paramValueMap.get(leftValue) != null) {
                        leftValue = paramValueMap.get(leftValue).getValue();
                    } else {
                        leftValue = TO_DATE_EXPRESSION_PREFIX + leftValue + TO_DATE_EXPRESSION_POSTFIX;
                    }
                    String rightValue = condNode.getValueRight();
                    if (paramValueMap.get(rightValue) != null) {
                        rightValue = paramValueMap.get(rightValue).getValue();
                    } else {
                        rightValue = TO_DATE_EXPRESSION_PREFIX + rightValue + TO_DATE_EXPRESSION_POSTFIX;
                    }

                    BetweenConditionExpressionNode newNode = new BetweenConditionExpressionNode(
                            "OPERATION_ID",
                            condNode.getOperator(),
                            FROM_ID_EXPRESSION_PREFIX + leftValue + ID_EXPRESSION_POSTFIX,
                            TILL_ID_EXPRESSION_PREFIX + rightValue + ID_EXPRESSION_POSTFIX);
                    iterator.remove();
                    iterator.add(newNode);
                }
            }
            if (node instanceof ExpressionNodeList) {
                replaceHostDate((ExpressionNodeList) node);
            }
        }
    }

    public void downloadFile()
            throws IOException {
        if(reportFormat==null)
            return;
      //  ReportFormat reportFormatItem = (ReportFormat)reportFormat.getValue();
        logger.debug("Begin file downloading");


        FacesContext fc = FacesContext.getCurrentInstance();
        ExternalContext ec = fc.getExternalContext();
        // Some JSF component library or some Filter might have set some headers
        // in the buffer beforehand. We want to get rid of them, else it may
        // collide.
        ec.responseReset();
        // Check http://www.iana.org/assignments/media-types for all types. Use
        // if necessary ExternalContext#getMimeType() for auto-detection based
        // on filename.
        ec.setResponseContentType(reportFormat.getContentType());
        // Set it with the file size. This header is optional. It will work if
        // it's omitted, but the download progress will be unknown.
        // ec.setResponseContentLength(contentLength);
        // The Save As popup magic is done here. You can give it any file name
        // you want, this only won't work in MSIE, it will use current request
        // URL as file name instead.
        Transliteration trs = new Transliteration();
        if(name!=null){
            name = trs.transliterate(name);
        }
        ec.setResponseHeader("Content-Disposition", "attachment; filename=\""
                + name + '.' + reportFormat.getExtension() + "\"");
        OutputStream output = ec.getResponseOutputStream();

        // Now you can write the InputStream of the file to the above
        // OutputStream the usual way.
        try {
            exportResult.writeTo(output);
        }
        finally {
            output.close();
            exportResult.close();
        }
        // Important! Otherwise JSF will attempt to render the response which
        // obviously will fail since it's already written with a file and
        // closed.
        fc.responseComplete();
        logger.debug("File downloaded");
    }


    public void exportReport(Long reportTemplateId){
        if(reportFormat==null)
            return;
        initReportTemplate(reportTemplateId);
        try {
            report.export(exportResult, 0, getEnvironment().getMaxReportRecords(), reportFormat.getType());
        } catch (ReportException e) {
            logger.error("Error while exporting report");
        }
    }

    class ReportFormat{
        final ExportReportContext.ExportType type;
        final String contentType;
        final String extension;
        ReportFormat(ExportReportContext.ExportType type, String contentType, String extension) {
            this.type = type;
            this.contentType = contentType;
            this.extension = extension;
        }

        public ExportReportContext.ExportType getType() {
            return type;
        }

        public String getContentType() {
            return contentType;
        }

        public String getExtension() {
            return extension;
        }

        @Override
        public String toString() {
            return type.name();
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;

            ReportFormat that = (ReportFormat) o;

            if (type != that.type) return false;

            return true;
        }

        @Override
        public int hashCode() {
            return type.hashCode();
        }
    }

    public List<ReportFormat> getReportFormatList() {
        if (reportFormatList == null) {
            reportFormatList = new ArrayList<ReportFormat>();
            reportFormatList.add(new ReportFormat(ExportReportContext.ExportType.XLS, "application/vnd.ms-excel", "xls"));
            reportFormatList.add(new ReportFormat(ExportReportContext.ExportType.PDF, "application/pdf", "pdf"));
            reportFormatList.add(new ReportFormat(ExportReportContext.ExportType.HTML, "text/html", "html"));
        }
        return reportFormatList;
    }

    public ReportFormat getReportFormat() {
        return reportFormat;
    }

    public void setReportFormat(ReportFormat reportFormat) {
        this.reportFormat = reportFormat;
    }

    public void setReportFormat(ExportReportContext.ExportType reportFormat) {
        for(ReportFormat format:getReportFormatList()){
            if(reportFormat.equals(format.getType())){
                this.reportFormat = format;
            }
        }
    }
}
