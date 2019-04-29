package ru.bpc.sv2.ui.rules.disputes;

import org.apache.log4j.Logger;
import ru.bpc.sv2.application.DspApplication;
import ru.bpc.sv2.constants.DataTypes;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.constants.reports.ReportConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.ReportsDao;
import ru.bpc.sv2.reports.Report;
import ru.bpc.sv2.reports.ReportParameter;
import ru.bpc.sv2.reports.ReportTemplate;
import ru.bpc.sv2.ui.reports.MbReports;
import ru.bpc.sv2.ui.reports.ReportRunner;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbDspLetter")
public class MbDspLetter extends AbstractBean {
    private static final long serialVersionUID = 1L;
    private static final Logger logger = Logger.getLogger("REPORTS");
    private static final String I_APPL_ID = "I_APPL_ID";
    private static final String CASE_ACTION_LETTER = "CASE_ACTION_LETTER";
    private static final int DISPUTE_LETTERS_TAG = 1018;


    private Long applicationId;
    private Integer reportId;
    private Integer templateId;
    private String fileFormat;
    private ReportRunner runner;
    private Report report;
    private ReportTemplate template;
    private List<ReportParameter> parameters;
    private List<Filter> filters;
    private List<DspApplication> applications;
    private Map<Integer, List<SelectItem>> lovs;
    private String module;

    private ReportsDao reportDao = new ReportsDao();
    private ApplicationDao applicationDao = new ApplicationDao();

    public MbDspLetter() {
        runner = new ReportRunner(userSessionId);
    }

    public Long getApplicationId() {
        return applicationId;
    }
    public void setApplicationId(Long applicationId) {
        this.applicationId = applicationId;
    }

    public Integer getReportId() {
        return reportId;
    }
    public void setReportId(Integer reportId) {
        this.reportId = reportId;
    }

    public Integer getTemplateId() {
        return templateId;
    }
    public void setTemplateId(Integer templateId) {
        this.templateId = templateId;
    }

    public String getFileFormat() {
        return fileFormat;
    }
    public void setFileFormat(String fileFormat) {
        this.fileFormat = fileFormat;
    }

    public List<SelectItem> getTemplates() {
        if(module == null) {
            return getDictUtils().getLov(LovConstants.DISPUTE_LETTER_TEMPLATES);
        } else {
            if (module.equals(ApplicationConstants.TYPE_ISSUING)) {
                return getDictUtils().getLov(LovConstants.ISSUING_LETTER_TEMPLATES);
            } else {
                return getDictUtils().getLov(LovConstants.ACQUIRING_LETTER_TEMPLATES);
            }
        }
    }
    public List<SelectItem> getFileFormates() {
        return getDictUtils().getLov(LovConstants.LETTER_FORMATS);
    }

    public Report getReport() {
        return report;
    }
    public void setReport(Report report) {
        this.report = report;
    }

    public ReportTemplate getTemplate() {
        return template;
    }
    public void setTemplate(ReportTemplate template) {
        this.template = template;
    }

    public List<ReportParameter> getParameters() {
        return parameters;
    }
    public void setParameters(List<ReportParameter> parameters) {
        this.parameters = parameters;
    }

    public List<DspApplication> getApplications() {
        return applications;
    }
    public void setApplications(List<DspApplication> applications) {
        this.applications = applications;
    }

    public String getModule() {
        return module;
    }
    public void setModule(String module) {
        this.module = module;
    }

    public boolean isDisableCreation() {
        if (applicationId == null && applications == null) {
            return true;
        } else if (templateId == null) {
            return true;
        } else if (fileFormat == null) {
            return true;
        }
        return false;
    }

    public void createLetter() {
        if (parameters != null) {
            for (ReportParameter param : parameters) {
                if (Boolean.TRUE.equals(param.getMandatory())) {
                    if (!I_APPL_ID.equalsIgnoreCase(param.getSystemName())) {
                        if (param.getValue() == null || param.getValue().toString().trim().isEmpty()) {
                            FacesUtils.addMessageError("Mandatory field '" +
                                                       ((param.getName() != null) ? param.getName() : param.getSystemName()) +
                                                       "' is not filled");
                            return;
                        }
                    }
                }
            }
        }

        try {
            findReport();
            if (applicationId != null) {
                runner.runReport(report, fileFormat, getReportParameters(applicationId), templateId);
                Map<String, Object> params = new HashMap<String, Object>();
                params.put("applId", applicationId);
                params.put("action", CASE_ACTION_LETTER);
                params.put("param", templateId.toString());
                applicationDao.addDisputeHistory(userSessionId, params);
                params.clear();
            } else if (applications != null) {
                for (DspApplication app : applications) {
                    runner.runReport(report, fileFormat, getReportParameters(app.getId()), templateId);
                    Map<String, Object> params = new HashMap<String, Object>();
                    params.put("applId", app.getId());
                    params.put("action", CASE_ACTION_LETTER);
                    params.put("param", templateId.toString());
                    applicationDao.addDisputeHistory(userSessionId, params);
                    params.clear();
                    MbReports bean = (MbReports) ManagedBeanWrapper.getManagedBean("MbReports");
                    if (bean != null) {
                        bean.setFileName(runner.getFilename());
                        bean.setReportFormat(runner.getReportFormat());
                        bean.setOutFile(runner.getOutFile());
                    }
                }
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    private void setFilters() {
        filters = new ArrayList<Filter>();
        Filter paramFilter = new Filter();
        paramFilter.setElement("lang");
        paramFilter.setOp(Filter.Operator.eq);
        paramFilter.setValue(userLang);
        filters.add(paramFilter);

        paramFilter = new Filter();
        paramFilter.setElement("id");
        paramFilter.setOp(Filter.Operator.like);
        paramFilter.setValue(reportId.toString());
        filters.add(paramFilter);
    }

    private void findReportId() throws DataAccessException {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("templateId", templateId);
        params.put("lang", userLang);
        setReportId(reportDao.getReportIdByTemplate(userSessionId, params));
    }

    private void findReport() throws DataAccessException {
        findReportId();
        setFilters();
        SelectionParams params = new SelectionParams();
        params.setFilters(filters.toArray(new Filter[filters.size()]));
        Report[] result = reportDao.getReportsList(userSessionId, params);
        if (result.length > 0) {
            setReport(result[0]);
        } else {
            throw new DataAccessException("Report hasn't been found");
        }
    }

    private ReportParameter[] getReportParameters(Long applId) {
        if (parameters == null || parameters.size() == 0) {
            ReportParameter[] params = new ReportParameter[1];
            ReportParameter param = new ReportParameter();
            param.setReportId(reportId);
            param.setDataType(DataTypes.NUMBER);
            param.setValueN(BigDecimal.valueOf(applId));
            param.setSystemName(I_APPL_ID);
            param.setName("Application ID");
            param.setLang(userLang);
            param.setMandatory(true);
            params[0] = param;
            return params;
        } else {
            for (ReportParameter param : parameters) {
                if (I_APPL_ID.equalsIgnoreCase(param.getSystemName())) {
                    param.setValueN(BigDecimal.valueOf(applId));
                    break;
                }
            }
            return parameters.toArray(new ReportParameter[parameters.size()]);
        }
    }

    public void generateFile() {
        try {
            runner.generateFile();
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public boolean isHtmlReport() {
        return ReportConstants.REPORT_FORMAT_HTML.equals(fileFormat);
    }

    public void findTemplate() {
        if (templateId != null) {
            try {
                template = reportDao.getReportTemplate(userSessionId, templateId, userLang);
                parameters = reportDao.getReportParameters(userSessionId, template.getReportId(), userLang);
                lovs = new HashMap<Integer, List<SelectItem>>();
                for (ReportParameter param : parameters) {
                    if (param.getLovId() != null) {
                        lovs.put(param.getLovId(), getDictUtils().getLov(param.getLovId()));
                    }
                }
            } catch (Exception e) {
                logger.error("", e);
            }
        } else {
            template = null;
            parameters = null;
            lovs = null;
        }
    }

    public Map<Integer, List<SelectItem>> getLovs() {
        if (lovs == null) {
            lovs = new HashMap<Integer, List<SelectItem>>(0);
        }
        return lovs;
    }

    public boolean isShowParameters() {
        if (parameters != null) {
            for (ReportParameter param : parameters) {
                if (!I_APPL_ID.equalsIgnoreCase(param.getSystemName())) {
                    return true;
                }
            }
        }
        return false;
    }

    @Override
    public void clearFilter() {
        templateId = null;
        template = null;
        parameters = null;
        lovs = null;
        applications = null;
        applicationId = null;
        filters = new ArrayList<Filter>();
    }
}
