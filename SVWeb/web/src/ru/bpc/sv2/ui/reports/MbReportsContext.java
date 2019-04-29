package ru.bpc.sv2.ui.reports;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.openfaces.util.Faces;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.reports.ReportConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ReportsDao;
import ru.bpc.sv2.reports.Report;
import ru.bpc.sv2.reports.ReportParameter;
import ru.bpc.sv2.reports.ReportTemplate;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbReportsContext")
public class MbReportsContext extends AbstractBean {
	private static final long serialVersionUID = 1L;
	
	private static final Logger logger = Logger.getLogger("REPORTS");

	private ReportsDao _reportsDao = new ReportsDao();

	private transient DictUtils dictUtils;

	private Report _activeReport;

	private Integer templateId;
	private String reportFormat;

	private ReportParameter[] reportParameters;
	private ReportRunner reportRunner;
	
	private Long userSessionId;
	private String curLang;
	private String userLang;
	
	public MbReportsContext() {
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		userLang = curLang = SessionWrapper.getField("language");
		
		reportRunner = new ReportRunner(userSessionId);
	}

    @Override
    public void clearFilter() {
        // do nothing
    }

    public String getFilename(String extension) {
		GregorianCalendar gc = new GregorianCalendar();

		return "" + gc.get(Calendar.YEAR) + (gc.get(Calendar.MONTH) + 1)
				+ gc.get(Calendar.DAY_OF_MONTH) + "." + extension;
	}
    
    public void runReportt() {
    	runReport();
    }

	public boolean runReport() {
		try {
			reportRunner.runReport(_activeReport, reportFormat, reportParameters, templateId);
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return false;
		} finally {
			//
		}

		return true;
	}

	public void generateFile() {
		try {
			reportRunner.generateFile();
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}

	public ArrayList<SelectItem> getTemplates() {
		ArrayList<SelectItem> items = null;
		try {
			if (_activeReport == null || _activeReport.getId() == null) {
				return new ArrayList<SelectItem>(0);
			}
			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(-1);

			List<Filter> filtersList = new ArrayList<Filter>();
			Filter paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(userLang);
			filtersList.add(paramFilter);

			paramFilter = new Filter();
			paramFilter.setElement("reportId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(_activeReport.getId());
			filtersList.add(paramFilter);

			params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));
			ReportTemplate[] templates = _reportsDao.getReportTemplates(userSessionId, params);
			items = new ArrayList<SelectItem>();
			for (ReportTemplate template : templates) {
				items.add(new SelectItem(template.getId(), template.getId() + " - "
						+ template.getName(), template.getDescription()));
			}

		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		} finally {
			if (items == null)
				items = new ArrayList<SelectItem>();
		}

		return items;
	}

	public Integer getTemplateId() {
		return templateId;
	}

	public void setTemplateId(Integer templateId) {
		this.templateId = templateId;
	}

	public boolean isActiveReportXml() {
		if (_activeReport == null) {
			return false;
		}
		return _activeReport.isXml();
	}

	public List<SelectItem> getActiveReportListValues() {
		List<SelectItem> list = null;
		try {
			ReportParameter param = (ReportParameter) Faces.var("item");
			if (param != null && param.getLovId() != null) {
				list = getDictUtils().getLov(param.getLovId());
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		if (list == null) {
			list = new ArrayList<SelectItem>(0);
		}
		return list;
	}

	public void cancelReport() {
	}
	
	@SuppressWarnings("unchecked")
	public void initializeModalPanell() {
		initializeModalPanel();
	}

	@SuppressWarnings("unchecked")
	public boolean initializeModalPanel() {
		clearBean();

		if (FacesUtils.getSessionMapValue("CTX_MENU_PARAMS") != null) {
			// if parameters packed in map
			
			Map<String, Object> ctxMenuParams = (Map<String, Object>) FacesUtils
					.getSessionMapValue("CTX_MENU_PARAMS");
			FacesUtils.setSessionMapValue("CTX_MENU_PARAMS", null);

			if (ctxMenuParams.get("REPORT_ID") != null) {
				Integer reportId = ((BigDecimal) ctxMenuParams.get("REPORT_ID")).intValue();

				_activeReport = getReportById(reportId);
				if (_activeReport == null) {
					FacesUtils.addErrorExceptionMessage("Report with ID = " + reportId + " was not found.");
					return false;
				}
			} else {
				FacesUtils.addErrorExceptionMessage("Report ID is not set.");
				return false;
			}

			if (ctxMenuParams.get("REPORT_TEMPLATE_ID") != null) {
				templateId = ((BigDecimal) ctxMenuParams.get("REPORT_TEMPLATE_ID")).intValue();
			} else {
				templateId = getTemplateId(_activeReport.getId());
				if (templateId == null) {
					FacesUtils.addErrorExceptionMessage("Template for report \""
							+ _activeReport.getName() + "\" was not found.");
					return false;
				}
			}
			if (ctxMenuParams.get("REPORT_FORMAT") != null) {
				reportFormat = ((String) ctxMenuParams.get("REPORT_FORMAT"));
			} 

			reportParameters = getReportParamsByReportId(_activeReport.getId());

			for (ReportParameter param : reportParameters) {
				if (ctxMenuParams.get(param.getSystemName()) != null) {
					if (param.isChar()) {
						param.setValueV((String) ctxMenuParams.get(param.getSystemName()));
					} else if (param.isNumber()) {
						param.setValueN((BigDecimal) ctxMenuParams.get(param.getSystemName()));
					} else if (param.isDate()) {
						param.setValueD((Date) ctxMenuParams.get(param.getSystemName()));
					}
				}
			}
		} else {
			// if parameters are passed separately
			if (FacesUtils.getSessionMapValue("REPORT_ID") != null) {
				Integer reportId = ((BigDecimal) FacesUtils.getSessionMapValue("REPORT_ID")).intValue();
				FacesUtils.setSessionMapValue("REPORT_ID", null);
	
				_activeReport = getReportById(reportId);
				if (_activeReport == null) {
					FacesUtils.addErrorExceptionMessage("Report with ID = " + reportId + " was not found.");
					return false;
				}
			} else {
				FacesUtils.addErrorExceptionMessage("Report ID is not set.");
				return false;
			}
			
			if (FacesUtils.getSessionMapValue("REPORT_TEMPLATE_ID") != null) {
				templateId = ((BigDecimal) FacesUtils.getSessionMapValue("REPORT_TEMPLATE_ID")).intValue();
			} else {
				templateId = getTemplateId(_activeReport.getId());
				if (templateId == null) {
					FacesUtils.addErrorExceptionMessage("Template for report \""
							+ _activeReport.getName() + "\" was not found.");
					return false;
				}
			}
			
			if (FacesUtils.getSessionMapValue("REPORT_FORMAT") != null) {
				reportFormat = ((String) FacesUtils.getSessionMapValue("REPORT_FORMAT"));
			} else {
				
			}
		}
		
		if (_activeReport == null) {
			FacesUtils.addErrorExceptionMessage("Report ID is not set or report was not found");
		}
		if (reportParameters == null) {
			reportParameters = getReportParamsByReportId(_activeReport.getId());
		}
		
		if (FacesUtils.getSessionMapValue("reportParams") != null) {
			Map<String, ReportParameter> mergeParams = (Map<String, ReportParameter>) FacesUtils
					.getSessionMapValue("reportParams");

			if (reportParameters == null) {
				reportParameters = getReportParamsByReportId(_activeReport.getId());
			}

			if (mergeParams != null && !mergeParams.isEmpty()) {
				for (ReportParameter param : reportParameters) {
					ReportParameter paramTmp = mergeParams.get(param.getSystemName());
					if (paramTmp == null) {
						continue;
					}
					if (param.isChar()) {
						param.setValueV(paramTmp.getValueV());
					} else if (param.isNumber()) {
						param.setValueN(paramTmp.getValueN());
					} else if (param.isDate()) {
						param.setValueD(paramTmp.getValueD());
					}
				}
			}
		}
		if (reportParameters == null) {
			reportParameters = new ReportParameter[0];
		}
		return true;
	}

	private Report getReportById(Integer reportId) {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(curLang);
		filters[1] = new Filter();
		filters[1].setElement("id");
		filters[1].setValue(reportId);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Report[] reports = _reportsDao.getReportsList(userSessionId, params);
			if (reports != null && reports.length > 0) {
				return reports[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	private ReportParameter[] getReportParamsByReportId(Long reportId) {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(curLang);
		filters[1] = new Filter();
		filters[1].setElement("reportId");
		filters[1].setValue(reportId);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			return _reportsDao.getReportParameters(userSessionId, params);
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return new ReportParameter[0];
	}

	private Integer getTemplateId(Long reportId) {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(curLang);
		filters[1] = new Filter();
		filters[1].setElement("reportId");
		filters[1].setValue(reportId);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			ReportTemplate[] templates = _reportsDao.getReportTemplatesLight(userSessionId, params);
			if (templates.length > 0) {
				return templates[0].getId();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return null;
	}
	
	public String getReportFormat() {
		return reportFormat;
	}

	public void setReportFormat(String reportFormat) {
		this.reportFormat = reportFormat;
	}

	public List<SelectItem> getFormats() {
		return getDictUtils().getLov(LovConstants.REPORT_TEMPLATE_FORMATS);
	}

	public ReportParameter[] getReportParameters() {
		return reportParameters;
	}

	public void setReportParameters(ReportParameter[] reportParameters) {
		this.reportParameters = reportParameters;
	}

	public boolean isHtmlReport() {
		return ReportConstants.REPORT_FORMAT_HTML.equals(reportFormat);
	}

	public void clearBean() {
		reportParameters = null;
		_activeReport = null;
	}
	
	public String runReportImmediately() {
		if (!initializeModalPanel()) {
			return null;
		}
		if (!runReport()) {
			return null;
		}
		generateFile();
		return null;
	}

	public DictUtils getDictUtils() {
		if (dictUtils == null) {
			dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
		}
		return dictUtils;
	}
}
