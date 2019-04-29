package ru.bpc.sv2.ui.reports;

import org.apache.log4j.Logger;
import org.openfaces.util.Faces;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.administrative.roles.ComplexRole;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.reports.ReportConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ReportsDao;
import ru.bpc.sv2.logic.RolesDao;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.reports.Report;
import ru.bpc.sv2.reports.ReportParameter;
import ru.bpc.sv2.reports.ReportTemplate;
import ru.bpc.sv2.system.TemplateCompiler;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;
import util.auxil.ManagedBeanWrapper;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbReportsBottom")
public class MbReportsBottom extends AbstractBean {	
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("REPORTS");

	private final String XML_SOURCE = "RPTSSXML";

	private static final String DETAILS_TAB = "detailsTab";

	private ReportsDao _reportsDao = new ReportsDao();

	private SettingsDao _settingsDao = new SettingsDao();

	private RolesDao _rolesDao = new RolesDao();

	private MbReports mbReports;
	private MbReportParametersSearch mbReportParametersSearch;
	
	private Report filter;
	private Report newReport;

	private Integer templateId;
	private String reportFormat;

	private ArrayList<SelectItem> institutions;

	private boolean blockInstitution;
	private String tabName;

	private ArrayList<SelectItem> roles;	
	
	private ReportParameter[] reportParameters;
	private int parametersHashCode = -1;
	private HashMap<Integer, ReportTemplate> reportTemplates;
	
	private Integer[] editingReportTagsIds;
	private Integer tagIdFilter;
	private Report activeItem;
	private Report detailItem;
	private DaoDataModel<Report> dataModel;
	private final TableRowSelection<Report> tableRowSelection;
	private String entityType;
	private String objectType;
	private Long objectId;
	private boolean showDialog;
	
	private ReportRunner reportRunner;
	
	public MbReportsBottom() {
		mbReports = (MbReports) ManagedBeanWrapper.getManagedBean("MbReports");

		reportRunner = new ReportRunner(userSessionId);

		dataModel = new DaoDataModel<Report>(){
			private static final long serialVersionUID = 1L;

			@Override
			protected Report[] loadDaoData(SelectionParams params) {
				Report[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = _reportsDao.getReportsList(userSessionId, params);
					}catch (DataAccessException e){
			    		FacesUtils.addMessageError(e);
    					logger.error("", e);
					}
				} else {
					result = new Report[0];
				}
				return result;
			}
			
			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				int result = 0;
				if (searching){
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = _reportsDao.getReportsCount(userSessionId, params);
					}catch (DataAccessException e){
			    		FacesUtils.addMessageError(e);
    					logger.error("", e);						
					}
				} else {
					result = 0;
				}
				return result;
			}
		};
		tableRowSelection = new TableRowSelection<Report>(null, dataModel);
	}


	public void search() {
		curMode = VIEW_MODE;
		clearState();
		searching = true;
		mbReports.setSearching(searching);
		mbReports.setFilter(filter);
	}
	
	public void clearFilter() {
		filter = null;
		tagIdFilter = null;
		searching = false;
		mbReports.setSearching(searching);
		mbReports.setFilter(filter);
		clearState();
	}

	public Report getFilter() {
		if (filter == null) {
			filter = new Report();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(Report filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId().toString());
			filters.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}

		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getName().trim().replaceAll("[*]", "%").replaceAll("[?]",
					"_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getDescription() != null && filter.getDescription().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("description");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getDescription().trim().replaceAll("[*]", "%").replaceAll(
					"[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getSourceType() != null && filter.getSourceType().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("sourceType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getSourceType());
			filters.add(paramFilter);
		}
		
		if (tagIdFilter != null){
			paramFilter = new Filter();
			paramFilter.setElement("tagId");
			paramFilter.setValue(tagIdFilter);
			filters.add(paramFilter);
		}
		
		if(entityType!=null){
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setValue(entityType);
			filters.add(paramFilter);
		}
		
		if(objectType!=null){
			paramFilter = new Filter();
			paramFilter.setElement("objectType");
			paramFilter.setValue(objectType);
			filters.add(paramFilter);
		}

	}
	public void run() {
		templateId = null;
		showDialog = false;
		prepareReportParametersCopy();
	}
	
	public void prepareReportParametersCopy(){
		reportParameters = _reportsDao.getReportParameters(userSessionId, SelectionParams.build("reportId", activeItem.getId().intValue(), "lang", curLang));
		for(int i=0; i<reportParameters.length; i++){
			String code = reportParameters[i].getSystemName();

			if(code.equals("I_ENTITY_TYPE")){
				reportParameters[i].setValueV(getEntityType());
			} else if(code.equals("I_OBJECT_TYPE")){
				reportParameters[i].setValueV(getObjectType());
			} else if(code.equals("I_OBJECT_ID")){
				reportParameters[i].setValueN(BigDecimal.valueOf(getObjectId()));
			} else{
				showDialog = true;
			}
		}
		
	}	

	public void runReport() {
		try {
			ReportParameter[] paramsArr = null;
			if (reportParameters == null) {
				paramsArr = new ReportParameter[0];
			} else {
				paramsArr = reportParameters;
			}
			reportRunner.runReport(activeItem, reportFormat, paramsArr, templateId);
			
			// TODO: do we really need this?
			mbReports.setFileName(reportRunner.getFilename());
			mbReports.setReportFormat(reportRunner.getReportFormat());
			mbReports.setOutFile(reportRunner.getOutFile());
			
			cancelReport();
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			mbReports.clearReportData();
		} finally {
			
		}
	}

	public void generateFile() {
		try {
			reportRunner.generateFile();
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}


	public void clearState() {
		tableRowSelection.clearSelection();
		activeItem = null;
		detailItem = null;
		dataModel.flushCache();
		curLang = userLang;		
	}

	public ArrayList<SelectItem> getSourceTypes() {
		return getDictUtils().getArticles(DictNames.REPORT_SOURCE_TYPES, false, false);
	}

	public Report getRefreshedReport() {
		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(activeItem.getId().toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);

		filters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			Report[] reports = _reportsDao.getReportsList(userSessionId, params);
			if (reports != null && reports.length > 0) {
				return reports[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return new Report();
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailItem = getNodeByLang(detailItem.getId(), curLang);
	}
	
	public Report getNodeByLang(Long id, String lang) {
		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(id.toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(lang);
		filtersList.add(paramFilter);

		filters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
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

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public ArrayList<SelectItem> getRoles() {
		roles = null;

		Filter[] filters = new Filter[1];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(curLang);

		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(-1);
		params.setFilters(filters);
		try {
			ComplexRole[] rolesList = _rolesDao.getRoles(userSessionId, params);
			roles = new ArrayList<SelectItem>(rolesList.length);
			for (ComplexRole role: rolesList) {
				roles.add(new SelectItem(role.getId(), role.getShortDesc(), role.getFullDesc()));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}

		if (roles == null)
			roles = new ArrayList<SelectItem>(0);

		return roles;
	}

	public ArrayList<SelectItem> getTemplates() {
		ArrayList<SelectItem> items = null;
		try {
			if (activeItem == null || activeItem.getId() == null) {
				return new ArrayList<SelectItem>(0);
			}

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(userLang);
			filters[1] = new Filter();
			filters[1].setElement("reportId");
			filters[1].setValue(activeItem.getId());

			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(-1);
			params.setFilters(filters);
			ReportTemplate[] templates = _reportsDao.getReportTemplates(userSessionId, params);
			items = new ArrayList<SelectItem>(templates.length);
			reportTemplates = new HashMap<Integer, ReportTemplate>(templates.length);
			for (ReportTemplate template: templates) {
				items.add(new SelectItem(template.getId(), template.getId() + " - "
						+ template.getName(), template.getDescription()));
				reportTemplates.put(template.getId(), template);
			}
			if (templateId == null && templates.length > 0) {
				templateId = (Integer) items.get(0).getValue();
				setDefaultFormat();
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
	
	public void setDefaultFormat() {
		ReportTemplate template = reportTemplates.get(getTemplateId());
		if (template != null) {
			setReportFormat(template.getFormat());
		} else {
			setReportFormat(null);
		}
	}


	public Integer getTemplateId() {
		return templateId;
	}

	public void setTemplateId(Integer templateId) {
		this.templateId = templateId;
	}

	public boolean isActiveReportXml() {
		if (activeItem == null) {
			return false;
		}
		return activeItem.isXml();
	}

	public void setActiveReport(Report report) throws Exception {
		setActiveReportWithParams(report, null);
	}

	public void setActiveReportWithParams(Report report, Map<String, ReportParameter> params)
			throws Exception {
		activeItem = report;
		if (activeItem != null && activeItem.getId() != null) {
			MbReportParametersSearch paramsSearch = (MbReportParametersSearch) ManagedBeanWrapper
					.getManagedBean("MbReportParametersSearch");
			ReportParameter paramFilter = new ReportParameter();
			paramFilter.setReportId(activeItem.getId().intValue()); // Report's ID is actually an integer
			paramsSearch.setFilter(paramFilter);
			paramsSearch.setMergeParams(params);
			paramsSearch.searchAndMerge();
		}
	}

	public boolean isBlockInstitution() {
		return blockInstitution;
	}


	public List<SelectItem> getDsProcedures() {
		List<SelectItem> items = getDictUtils().getLov(LovConstants.XML_PROCEDURES);

		for (SelectItem item: items) {
			item.setValue(item.getLabel());
		}
		return items;
	}

	public void confirmEditLanguage() {
		curLang = newReport.getLang();
		Report tmp = getNodeByLang(newReport.getId(), newReport.getLang());
		if (tmp != null) {
			newReport.setName(tmp.getName());
			newReport.setDescription(tmp.getDescription());
		}
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		mbReports.setActiveTabName(tabName);
		
		if (tabName.equalsIgnoreCase("parametersTab")) {
			MbReportParametersSearch bean = (MbReportParametersSearch) ManagedBeanWrapper
					.getManagedBean("MbReportParametersSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}  else if (tabName.equalsIgnoreCase("templatesTab")) {
			MbReportTemplatesSearch bean = (MbReportTemplatesSearch) ManagedBeanWrapper
					.getManagedBean("MbReportTemplatesSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("rolesTab")) {
			MbReportRoles bean = (MbReportRoles) ManagedBeanWrapper
					.getManagedBean("MbReportRoles");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("entitiesTab")) {
			MbReportEntitiesSearch bean = (MbReportEntitiesSearch) ManagedBeanWrapper
					.getManagedBean("MbReportEntitiesSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));	
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.CONFIGURATION_RPT_REPORT;
	}
	
	public List<SelectItem> getActiveReportListValues(){
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

	public ReportParameter[] getReportParameters(){		
		return reportParameters;
	}
	
	public void cancelReport() {
		reportParameters = null;
		parametersHashCode = -1;
	}

	public String getReportFormat() {
		return reportFormat;
	}

	public void setReportFormat(String reportFormat) {
		this.reportFormat = reportFormat;
	}

	public List<SelectItem> getFormats() {
		if (templateId != null && reportTemplates.get(templateId) != null
				&& reportTemplates.get(templateId).isProcessorXslt()) {
			List<SelectItem> items = new ArrayList<SelectItem>(1);
			items.add(new SelectItem(ReportConstants.REPORT_FORMAT_HTML, getDictUtils()
					.getAllArticlesDesc().get(ReportConstants.REPORT_FORMAT_HTML)));
			items.add(new SelectItem(ReportConstants.REPORT_FORMAT_TEXT, getDictUtils()
					.getAllArticlesDesc().get(ReportConstants.REPORT_FORMAT_TEXT)));
			return items;
		}
		return getDictUtils().getLov(LovConstants.REPORT_TEMPLATE_FORMATS);
	}
	
	public boolean isHtmlReport() {
		return ReportConstants.REPORT_FORMAT_HTML.equals(reportFormat); 
	}
	
	public List<SelectItem> getTags() {
		List<SelectItem> tags = getDictUtils().getLov(LovConstants.REPORT_TAGS);
		return tags;
	}

	public List<SelectItem> getTagsByInstitute(){	                 
		if (newReport.getInstId() == null){
			return new ArrayList<SelectItem>(0);
		}
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("institution_id", newReport.getInstId());
		List<SelectItem> tags = getDictUtils().getLov(LovConstants.REPORT_TAGS, params);
		return tags;
	}
	
	public Integer[] getEditingReportTagsIds() {
		return editingReportTagsIds;
	}

	
	public void setEditingReportTagsIds(Integer[] editingReportTagsIds) {
		this.editingReportTagsIds = editingReportTagsIds;
	}

	
	public Integer getTagIdFilter() {
		return tagIdFilter;
	}

	
	public void setTagIdFilter(Integer tagIdFilter) {
		this.tagIdFilter = tagIdFilter;
	}

	public Report getActiveItem() {
		return activeItem;
	}

	public void setActiveItem(Report activeItem) {
		this.activeItem = activeItem;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (activeItem == null && dataModel.getRowCount() > 0){
				prepareItemSelection();
			} else if (activeItem != null && dataModel.getRowCount() > 0){
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(activeItem.getModelId());
				tableRowSelection.setWrappedSelection(selection);
				activeItem = tableRowSelection.getSingleSelection();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
		return tableRowSelection.getWrappedSelection();
	}
	
	public void prepareItemSelection() throws CloneNotSupportedException{
		dataModel.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeItem = (Report)dataModel.getRowData();
		selection.addKey(activeItem.getModelId());
		tableRowSelection.setWrappedSelection(selection);
		if (activeItem != null) {
			detailItem = (Report) activeItem.clone();
		}
	}
	
	public void setItemSelection(SimpleSelection selection) {
		try {
			tableRowSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (tableRowSelection.getSingleSelection() != null 
					&& !tableRowSelection.getSingleSelection().getId().equals(activeItem.getId())) {
				changeSelect = true;
			}
			activeItem = tableRowSelection.getSingleSelection();
			mbReports.setActiveReport(activeItem);
			if (activeItem != null) {
				if (changeSelect) {
					detailItem = (Report) activeItem.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public DaoDataModel<Report> getDataModel(){
		return dataModel;
	}
	
	private Integer successfullyCompiled = 0;
	
	public Integer getSuccessfullyCompiled(){
		return successfullyCompiled;
	}
	
	public void compileUncompiledReports(){
		successfullyCompiled = 0;
		logger.info("Templates compilation...");
		
		
		Filter[] filters = new Filter[]{
			new Filter("lang", SystemConstants.ENGLISH_LANGUAGE),
			new Filter("reportProcessor", ReportConstants.TEMPLATE_PROCESSOR_JASPER),
			new Filter("notCompiled", true)
		};
		
		SelectionParams params = new SelectionParams(filters);
		logger.debug("Obtaining not compiled templates...");
		ReportTemplate[] reportTemplates = _reportsDao.getReportTemplates(userSessionId, params);
		logger.debug("Templates have been obtained: " + reportTemplates.length);
		
		TemplateCompiler compiler = null;
		try {
			compiler = new TemplateCompiler();
			for (ReportTemplate template : reportTemplates){
				try {
					compiler.compile(template);
					_reportsDao.modifyReportTemplate(template);
					if (template.getTextBase64() != null){
						successfullyCompiled++;
					}
				} catch (SystemException e){
					logger.error("", e);
				} catch (UserException e) {
					logger.error("", e);					
				} catch (DataAccessException e){
					logger.error("", e);
				}
			}
		} finally {			
			
		}
		logger.debug("Templates have been successfully compiled: " + successfullyCompiled);		
	}
	

	public Report getDetailItem() {
		return detailItem;
	}

	public void setDetailItem(Report detailItem) {
		this.detailItem = detailItem;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public String getObjectType() {
		return objectType;
	}

	public void setObjectType(String objectType) {
		this.objectType = objectType;
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public boolean isShowDialog() {
		return showDialog;
	}
}

