package ru.bpc.sv2.ui.reports;

import org.apache.log4j.Logger;
import org.openfaces.util.Faces;
import org.richfaces.model.selection.SimpleSelection;

import com.ctc.wstx.exc.WstxParsingException;

import ru.bpc.sv2.administrative.roles.ComplexRole;
import ru.bpc.sv2.constants.*;
import ru.bpc.sv2.constants.reports.ReportConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ReportsDao;
import ru.bpc.sv2.logic.RolesDao;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.reports.Report;
import ru.bpc.sv2.reports.ReportParameter;
import ru.bpc.sv2.reports.ReportTag;
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
import java.lang.reflect.Field;
import java.math.BigDecimal;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbReportsSearch")
public class MbReportsSearch extends AbstractBean {
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

	private DaoDataModel<ReportParameter> parametersCopy;
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

	private ReportRunner reportRunner;

	public MbReportsSearch() {
		pageLink = "reports|reports";
		tabName = DETAILS_TAB;

//		thisBackLink = "reports|reports";
		mbReports = (MbReports) ManagedBeanWrapper.getManagedBean("MbReports");
		restoreBean = (Boolean) FacesUtils.getSessionMapValue(pageLink);
		reportRunner = new ReportRunner(userSessionId);
		if (Boolean.TRUE.equals(restoreBean)) {
			FacesUtils.setSessionMapValue(pageLink, Boolean.FALSE);
			searching = mbReports.isSearching();
			filter = mbReports.getFilter();
			tagIdFilter = mbReports.getTagIdFilter();
			tabName = mbReports.getActiveTabName();
			activeItem = mbReports.getActiveReport();
			if (activeItem != null) {
				getFilter().setInstId(activeItem.getInstId());
				setBeansState();
				try {
					detailItem = activeItem.clone();
				} catch (CloneNotSupportedException e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
			}
		} else if (restoreBean == null || !restoreBean) {
			restoreBean = Boolean.FALSE;    // just to be sure it's not NULL
		}
		mbReportParametersSearch = (MbReportParametersSearch) ManagedBeanWrapper.getManagedBean("MbReportParametersSearch");
		dataModel = new DaoDataModel<Report>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected Report[] loadDaoData(SelectionParams params) {
				Report[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try {
						result = _reportsDao.getReportsList(userSessionId, params);
					} catch (DataAccessException e) {
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
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try {
						result = _reportsDao.getReportsCount(userSessionId, params);
					} catch (DataAccessException e) {
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
	/*
	protected void loadTree() {
		if (!searching)
			return;
		coreItems = new ArrayList<Report>();
		try {

			setFilters();

			SelectionParams params = new SelectionParams();
			params.setFilters(filters.toArray(new Filter[filters.size()]));

			Report[] reports = _reportsDao.getReports(userSessionId, params);

			if (reports != null && reports.length > 0) {
				addNodes(0, coreItems, reports);
				if (nodePath == null) {
					if (currentNode == null) {
						// currentNode = coreItems.get(0);
						// setNodePath(new TreePath(currentNode, null));
					} else {
						setNodePath(new TreePath(currentNode, null));
					}
				}
			}
			if (currentNode != null) {
				setInfo();
			}
			treeLoaded = true;
		} catch (Exception ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}
	*/

	public boolean getNodeHasChildren() {
		return false;
	}

	public void setBeansState() {
		MbReportParametersSearch paramsSearch = (MbReportParametersSearch) ManagedBeanWrapper
				.getManagedBean("MbReportParametersSearch");
		ReportParameter paramFilter = new ReportParameter();
		paramFilter.setReportId(activeItem.getId().intValue());  // Report's ID is actually an integer
		paramsSearch.setFilter(paramFilter);
		paramsSearch.search();

		MbReportTemplatesSearch templatesSearch = (MbReportTemplatesSearch) ManagedBeanWrapper
				.getManagedBean("MbReportTemplatesSearch");
		ReportTemplate templateFilter = new ReportTemplate();
		templateFilter.setReportId(activeItem.getId().intValue()); // Report's ID is actually an integer
		templatesSearch.setFilter(templateFilter);
		templatesSearch.search();

		MbReportRoles mbReportRoles = (MbReportRoles) ManagedBeanWrapper
				.getManagedBean("MbReportRoles");
		mbReportRoles.setReportId(activeItem.getId().intValue()); // Report's ID is actually an integer
		mbReportRoles.setBackLink(pageLink);
		mbReportRoles.search();

		MbReportOutParametersSearch bean = ManagedBeanWrapper
				.getManagedBean(MbReportOutParametersSearch.class);
		bean.getFilter().setReportId(getActiveItem().getId());
		bean.search();

		MbReportEntitiesSearch mbReportEntitiesSearch = (MbReportEntitiesSearch) ManagedBeanWrapper
				.getManagedBean("MbReportEntitiesSearch");
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("reportId", activeItem.getId().intValue());
		mbReportEntitiesSearch.setFilterMap(params);
		mbReportEntitiesSearch.search();
	}

	public void clearBeansStates() {
		MbReportParametersSearch paramsSearch = (MbReportParametersSearch) ManagedBeanWrapper
				.getManagedBean("MbReportParametersSearch");
		paramsSearch.clearState();
		paramsSearch.setFilter(null);
		paramsSearch.setSearching(false);

		MbReportTemplatesSearch templatesSearch = (MbReportTemplatesSearch) ManagedBeanWrapper
				.getManagedBean("MbReportTemplatesSearch");
		templatesSearch.clearState();
		templatesSearch.setFilter(null);
		templatesSearch.setSearching(false);

		MbReportRoles mbReportRoles = (MbReportRoles) ManagedBeanWrapper
				.getManagedBean("MbReportRoles");
		mbReportRoles.setSearching(false);

		MbReportEntitiesSearch mbReportEntitiesSearch = (MbReportEntitiesSearch) ManagedBeanWrapper
				.getManagedBean("MbReportEntitiesSearch");
		mbReportEntitiesSearch.setSearching(false);
	}

	public void search() {
		curMode = VIEW_MODE;
		clearState();
		clearBeansStates();
		searching = true;
		mbReports.setSearching(searching);
		mbReports.setFilter(filter);
		mbReports.setTagIdFilter(tagIdFilter);
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

		if (filter.getInstId() != null && 
				!filter.getInstId().equals(9999)) {
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

		if (tagIdFilter != null) {
			paramFilter = new Filter();
			paramFilter.setElement("tagId");
			paramFilter.setValue(tagIdFilter);
			filters.add(paramFilter);
		}

		if (entityType != null) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setValue(entityType);
			filters.add(paramFilter);
		}

		if (objectType != null) {
			paramFilter = new Filter();
			paramFilter.setElement("objectType");
			paramFilter.setValue(objectType);
			filters.add(paramFilter);
		}

	}

	public void add() {
		newReport = new Report();
		newReport.setLang(userLang);
		curLang = newReport.getLang();
		blockInstitution = false;
		curMode = NEW_MODE;
	}

	public void addGroup() {
		newReport = new Report();
		newReport.setSourceType(ReportConstants.SOURCE_TYPE_GROUP);
		newReport.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newReport = detailItem.clone();
			if (!newReport.getTags().isEmpty()) {
				editingReportTagsIds = new Integer[newReport.getTags().size()];
				int i = 0;
				for (ReportTag reportTag : newReport.getTags()) {
					editingReportTagsIds[i++] = reportTag.getId();
				}
			}

		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			newReport = activeItem;
		}
		blockInstitution = false;
		curMode = EDIT_MODE;
	}

	public void view() {

	}

	public void run() {
		templateId = null;
		mbReportParametersSearch.backupActiveParam();
		prepareReportParametersCopy();
	}

	public void prepareReportParametersCopy() {
		List<ReportParameter> parameters = mbReportParametersSearch.getParameters().getActivePage();

		if (parameters != null && !parameters.isEmpty() && parametersHashCode != parameters.hashCode()) {
			parametersHashCode = parameters.hashCode(); // Save it for comparison with the actual activePage.hashCode() in the future. This will prevent exessive memory coping and cpu.
			parametersCopy = mbReportParametersSearch.getParameters();
		}
	}

	public void setItemSelectionParameter(SimpleSelection selection) {
		mbReportParametersSearch.setItemSelection(selection);
	}

	public SimpleSelection getItemSelectionParameter() {
		return mbReportParametersSearch.getItemSelection();
	}

	public void runReport() {
		try {
			if(templateId != null) {
				ReportTemplate reportTemplate = reportTemplates.get(templateId);
				if (reportTemplate.getText() == null) {
					FacesUtils.addMessageError(new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Rpt", "template_file_needed")));
					return;
				}
			}
			String os = System.getProperty("os.name" );
			if (os.contains("SunOS")) {
				Field headlessField = java.awt.GraphicsEnvironment.class.getDeclaredField("headless");
				headlessField.setAccessible(true);
				headlessField.set(null, Boolean.TRUE);
				logger.debug(java.awt.GraphicsEnvironment.isHeadless());
			}
			ReportParameter[] paramsArr;
			if (parametersCopy == null) {
				paramsArr = new ReportParameter[0];
			} else {
				paramsArr = parametersCopy.getActivePage().toArray(new ReportParameter[parametersCopy.getActivePage().size()]);
			}
			reportRunner.runReport(activeItem, reportFormat, paramsArr, templateId);

			mbReportParametersSearch.getParameters().flushCache();
			mbReportParametersSearch.restoreActiveParam();

			// TODO: do we really need this?
			mbReports.setFileName(reportRunner.getFilename());
			mbReports.setReportFormat(reportRunner.getReportFormat());
			mbReports.setOutFile(reportRunner.getOutFile());

			cancelReport();
		} catch (WstxParsingException e) {
			logger.error("Parsing error: ", e);
			StringBuilder sb = new StringBuilder("XML Parsing error:\n");
			sb.append(e.getLocalizedMessage()).append("\n")
			.append("XML is probably malformed. Please check validity of the selected "
					+ "XML report template in the Database");
			FacesUtils.addMessageError(sb.toString());
			mbReports.clearReportData();		
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			mbReports.clearReportData();
		} catch (Throwable e){
			logger.error(e);
			FacesUtils.addMessageError(e.getMessage());
			mbReports.clearReportData();
		}

		// return null;
	}

	public void generateFile() {
		try {
			reportRunner.generateFile();
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}

	public void save() {
		try {
			// prepare tags to add and to remove for editing report
			List<Integer> tagsToAdd = null;
			List<Integer> tagsToRemove = null;
			if (editingReportTagsIds != null) {
				tagsToAdd = new ArrayList<Integer>();/*Arrays.asList(editingReportTagsIds);*/
				tagsToRemove = new ArrayList<Integer>();

				Collections.addAll(tagsToAdd, editingReportTagsIds);

				for (ReportTag reportTag : newReport.getTags()) {
					boolean removeTag = true;
					for (Integer editedTag : editingReportTagsIds) {
						if (reportTag.getId().equals(editedTag)) {
							tagsToAdd.remove(editedTag);
							removeTag = false;
							break;
						}
					}
					if (removeTag) {
						tagsToRemove.add(reportTag.getId());
					}

				}
			}

			if (isNewMode()) {
				newReport = _reportsDao.addReport(userSessionId, newReport, tagsToAdd);
				detailItem = newReport.clone();
				tableRowSelection.addNewObjectToList(newReport);
			} else if (isEditMode()) {
				newReport = _reportsDao.modifyReport(userSessionId, newReport, tagsToAdd, tagsToRemove);
				detailItem = newReport.clone();
				if (!userLang.equals(newReport.getLang())) {
					newReport = getNodeByLang(activeItem.getId(), userLang);
				}
				dataModel.replaceObject(activeItem, newReport);
			}
			activeItem = newReport;
			mbReports.setActiveReport(activeItem);
			setBeansState();
			close();
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_reportsDao.removeReport(userSessionId, activeItem);

			activeItem = tableRowSelection.removeObjectFromList(activeItem);
			if (activeItem == null) {
				clearBeansStates();
			} else {
				setBeansState();
				detailItem = activeItem.clone();
			}
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
		editingReportTagsIds = null;
		newReport = null;
	}

	public Report getNewReport() {
		if (newReport == null) {
			newReport = new Report();
		}
		return newReport;
	}

	public void setNewReport(Report newReport) {
		this.newReport = newReport;
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
			for (ComplexRole role : rolesList) {
				roles.add(new SelectItem(role.getId(), role.getShortDesc(), role.getFullDesc()));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (!e.getMessage().contains(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR)) {
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
			for (ReportTemplate template : templates) {
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
			if (!e.getMessage().contains(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR)) {
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

	public ArrayList<SelectItem> getReports() {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		try {

			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(-1);

			List<Filter> filtersList = new ArrayList<Filter>();
			Filter paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(userLang);
			filtersList.add(paramFilter);

			params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));
			Report[] reports = _reportsDao.getReports(userSessionId, params);
			for (Report report : reports) {
				boolean disabled = false;
				if (report.getId().equals(getNewReport().getId())) {
					disabled = true;
				}
				String name = report.getName();
				for (int i = 1; i < report.getLevel(); i++) {
					name = " -- " + name;
				}
				items.add(new SelectItem(report.getId(), name, report.getName(), disabled));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (!e.getMessage().contains(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR)) {
				FacesUtils.addMessageError(e);
			}
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
		return activeItem != null && activeItem.isXml();
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

	public boolean isXmlSource() {
		return XML_SOURCE.equals(getNewReport().getSourceType());
	}

	public List<SelectItem> getDsProcedures() {
		List<SelectItem> items = getDictUtils().getLov(LovConstants.XML_PROCEDURES);

		for (SelectItem item : items) {
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
		} else if (tabName.equalsIgnoreCase("imagesTab")) {
			MbReportImagesSearch bean = ManagedBeanWrapper.getManagedBean(MbReportImagesSearch.class);
			if (bean != null && activeItem != null) {
				bean.getFilter().setReportId(activeItem.getId());
				bean.search();
			}
		} else if (tabName.equalsIgnoreCase("templatesTab")) {
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

	public DaoDataModel<ReportParameter> getReportParameters() {
		return parametersCopy;
	}

	public void cancelReport() {
		parametersCopy = null;
		parametersHashCode = -1;
		mbReportParametersSearch.getParameters().flushCache();
		mbReportParametersSearch.restoreActiveParam();
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

	public List<SelectItem> getTagsByInstitute() {
		if (newReport.getInstId() == null) {
			return new ArrayList<SelectItem>(0);
		}
		Map<String, Object> params = new HashMap<String, Object>();
		if (!newReport.getInstId().equals(9999)){
			params.put("institution_id", newReport.getInstId());
		}
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
			if (activeItem == null && dataModel.getRowCount() > 0) {
				prepareItemSelection();
			} else if (activeItem != null && dataModel.getRowCount() > 0) {
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

	public void prepareItemSelection() throws CloneNotSupportedException {
		dataModel.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeItem = (Report) dataModel.getRowData();
		selection.addKey(activeItem.getModelId());
		tableRowSelection.setWrappedSelection(selection);
		if (activeItem != null) {
			setBeansState();
			detailItem = activeItem.clone();
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
				setBeansState();
				if (changeSelect) {
					detailItem = activeItem.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public DaoDataModel<Report> getDataModel() {
		return dataModel;
	}

	public List<SelectItem> getNameFormats() {
		if (getNewReport().getInstId() != null) {
			HashMap<String, Object> params = new HashMap<String, Object>(2);
			params.put("ENTITY_TYPE", EntityNames.REPORTS);
			params.put("INSTITUTION_ID", newReport.getInstId());

			return getDictUtils().getLov(LovConstants.NAME_FORMATS, params);
		}
		return new ArrayList<SelectItem>(0);
	}

	public List<SelectItem> getDocumentTypes() {
		return getDictUtils().getLov(LovConstants.DOCUMENT_TYPES);
	}

	private Integer successfullyCompiled = 0;

	public Integer getSuccessfullyCompiled() {
		return successfullyCompiled;
	}

	public void compileUncompiledReports() {
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

		TemplateCompiler compiler;
		compiler = new TemplateCompiler();
		for (ReportTemplate template : reportTemplates) {
			try {
				compiler.compile(template);
				_reportsDao.modifyReportTemplate(template);
				if (template.getTextBase64() != null) {
					successfullyCompiled++;
				}
			} catch (SystemException e) {
				logger.error("", e);
			} catch (UserException e) {
				logger.error("", e);
			} catch (DataAccessException e) {
				logger.error("", e);
			}
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

	public void setSelectValue(String valueParam) {
		ReportParameter activeParameter = mbReportParametersSearch.getActiveParameter();
		if (activeParameter.isChar()) {
			mbReportParametersSearch.getActiveParameter().setValueV(valueParam);
		}
		if (activeParameter.isNumber()) {
			mbReportParametersSearch.getActiveParameter().setValueN(new BigDecimal(valueParam));
		}
	}

	public String getSelectionForm() {
		String selectionForm;
		ReportParameter activeParameter = mbReportParametersSearch.getActiveParameter();
		if (activeParameter == null) {
			return null;
		}
		selectionForm = activeParameter.getSelectionForm();
		if (selectionForm == null || ManagedBeanWrapper.getManagedBean(selectionForm) == null) {
			return null;
		}

		return selectionForm;
	}

	public void setSelectedParValXml(String selectedParValXml) {
		getNewReport().setReportSource(selectedParValXml);
		save();
	}

	public String getSelectedParValXml() {
		return getNewReport().getReportSource();
	}

}

