package ru.bpc.sv2.ui.rules;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.FreqApplication;
import ru.bpc.sv2.common.application.ApplicationStatuses;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.process.ProcessTrace;
import ru.bpc.sv2.trace.TraceLogInfo;
import ru.bpc.sv2.ui.application.MbApplication;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.operations.MbOperationsBottom;
import ru.bpc.sv2.ui.process.monitoring.MbProcessTrace;
import ru.bpc.sv2.ui.utils.*;
import org.apache.commons.lang3.StringUtils;
import util.auxil.ManagedBeanWrapper;

import javax.annotation.PostConstruct;

import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.text.SimpleDateFormat;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbFreqApplications")
public class MbFreqApplications extends AbstractBean {
	private static final Logger logger = Logger.getLogger("RULES");
	public static final String FREQ_FILTER_KEY = "freqFilter";
	private static Logger loggerDB = Logger.getLogger("PROCESSES_DB");

	private static final String COMPONENT_ID = "1090:freqApplicationsTable";

	private ApplicationDao applicationDao = new ApplicationDao();

	private FreqApplication filter;
	private FreqApplication activeFreqApplication;
	private FreqApplication detailFreqApplication;
	private Date freqAppDateFrom;
	private Date freqAppDateTo;
	protected String tabName;

	private final DaoDataListModel<FreqApplication> freqApplicationSource;

	private TableRowSelection<FreqApplication> itemSelection;

	private String newStatus;

	List<SelectItem> entityTypes;

	public MbFreqApplications() {
		thisBackLink = "issuing|finrequests";
		tabName = "detailsTab";

		freqApplicationSource = new DaoDataListModel<FreqApplication>(logger) {
			@Override
			protected List<FreqApplication> loadDaoListData(SelectionParams params) {
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return applicationDao.getFreqApplications(userSessionId, params);
				}
				return new ArrayList<FreqApplication>();
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return applicationDao.getFreqApplicationsCount(userSessionId, params);
				}
				return 0;
			}
		};
		itemSelection = new TableRowSelection<FreqApplication>(null, freqApplicationSource);
	}

	@PostConstruct
	private void init() {
		Menu menu = ManagedBeanWrapper.getManagedBean("menu");
		MbApplication appBean = ManagedBeanWrapper.getManagedBean("MbApplication");
		if (!menu.isKeepState() && !appBean.isKeepState()) {
			searching = false;
			setDefaultValues();
		} else {
			menu.setKeepState(false);
			if (appBean.isKeepState()){
				appBean.setKeepState(false);
				activeFreqApplication = applicationDao.getFreqApplications(userSessionId, SelectionParams.build("id", appBean.getActiveApp().getId())).get(0);
				searching = true;
				filter = (FreqApplication) FacesUtils.extractSessionMapValue(FREQ_FILTER_KEY);
				pageNumber = appBean.getPageNumber();
				rowsNum = appBean.getRowsNum();
			}
		}

		if (activeFreqApplication != null) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(activeFreqApplication.getModelId());
			setItemSelection(selection);
		}
	}

	public DaoDataModel<FreqApplication> getFreqApplications() {
		return freqApplicationSource;
	}

	public FreqApplication getActiveFreqApplication() {
		return activeFreqApplication;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (activeFreqApplication == null && freqApplicationSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (activeFreqApplication != null && freqApplicationSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(activeFreqApplication.getModelId());
				itemSelection.setWrappedSelection(selection);
				activeFreqApplication = itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		itemSelection.setWrappedSelection(selection);
		activeFreqApplication = itemSelection.getSingleSelection();
		if (activeFreqApplication != null) {
			try {
				detailFreqApplication = (FreqApplication) activeFreqApplication.clone();
			} catch (CloneNotSupportedException e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		}
		loadTab(getTabName());
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		freqApplicationSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeFreqApplication = (FreqApplication) freqApplicationSource.getRowData();
		selection.addKey(activeFreqApplication.getModelId());
		itemSelection.setWrappedSelection(selection);
		if (activeFreqApplication != null) {
			detailFreqApplication = (FreqApplication) activeFreqApplication.clone();
		}
	}

	public void clearFilter() {
		filter = null;
		freqAppDateFrom = null;
		freqAppDateTo = null;
		curLang = userLang;
		clearBean();
		searching = false;
	}

	public void search() {
		curMode = VIEW_MODE;
		clearBean();
		searching = true;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		filters.add(new Filter("lang", userLang));

		if (filter.getId() != null) {
			filters.add(new Filter("id", filter.getId()));
		}

		if (filter.getStatus() != null) {
			filters.add(new Filter("status", filter.getStatus()));
		}

		if (filter.getAgentId() != null) {
			filters.add(new Filter("agentId", filter.getAgentId()));
		}

		if (StringUtils.isNotEmpty(filter.getEntityType())) {
			filters.add(Filter.create("entity_type", filter.getEntityType()));
		}

		if (filter.getObjectId() != null) {
			filters.add(Filter.create("object_id", filter.getObjectId()));
		}

		if (freqAppDateFrom != null) {
			filters.add(Filter.create("app_date_from", freqAppDateFrom));
		}
		if (freqAppDateTo != null) {
			filters.add(new Filter("app_date_to", freqAppDateTo));
		}
	}

	public FreqApplication getFilter() {
		if (filter == null) {
			filter = new FreqApplication();
		}
		return filter;
	}

	public void setFilter(FreqApplication filter) {
		this.filter = filter;
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public void clearBean() {
		itemSelection.clearSelection();
		activeFreqApplication = null;
		detailFreqApplication = null;
		freqApplicationSource.flushCache();
	}

	public String getSectionId() {
		return SectionIdConstants.OPERATION_MODIFIER_SCALE;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public FreqApplication getDetailFreqApplication() {
		return detailFreqApplication;
	}

	public void setDetailFreqApplication(FreqApplication detailFreqApplication) {
		this.detailFreqApplication = detailFreqApplication;
	}

	public List<SelectItem> getStatuses() {
		DictUtils dictUtils = ManagedBeanWrapper.getManagedBean(DictUtils.class);
		List<SelectItem> statuses = new ArrayList<SelectItem>();
		for (SelectItem item : dictUtils.getArticles(DictNames.AP_STATUSES)) {
			if (item.getValue().equals(ApplicationStatuses.READY_FOR_REVIEW) ||
				item.getValue().equals(ApplicationStatuses.ACCEPTED) ||
				item.getValue().equals(ApplicationStatuses.REJECTED))
				statuses.add(item);
		}
		return statuses;
	}

	public Date getFreqAppDateTo() {
		return freqAppDateTo;
	}

	public void setFreqAppDateTo(Date freqAppDateTo) {
		this.freqAppDateTo = freqAppDateTo;
	}

	public Date getFreqAppDateFrom() {
		return freqAppDateFrom;
	}

	public void setFreqAppDateFrom(Date freqAppDateFrom) {
		this.freqAppDateFrom = freqAppDateFrom;
	}

	public void submitForReview() {
		newStatus = ApplicationStatuses.READY_FOR_REVIEW;
	}

	public void accept() {
		try {
			curMode = VIEW_MODE;
			applicationDao.processApplication(userSessionId, activeFreqApplication.getId(), false);
			update(activeFreqApplication.getId(), EDIT_MODE);
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public void reject() {
		newStatus = ApplicationStatuses.REJECTED;
		curMode = VIEW_MODE;
	}

	public boolean isShowReasons() {
		return ApplicationStatuses.REJECTED.equals(newStatus);
	}

	public void changeStatus() {
		if (newStatus != null) {
			Application app = new Application();
			app.setId(activeFreqApplication.getId());
			app.setAppType(activeFreqApplication.getAppType());
			app.setAppSubType(activeFreqApplication.getAppSubType());
			app.setSeqNum(activeFreqApplication.getSeqNum());
			app.setNewStatus(newStatus);
			app.setComment(activeFreqApplication.getComment());
			app.setRejectCode(activeFreqApplication.getRejectCode());
			try {
				applicationDao.changeApplicationStatus(userSessionId, app);
				loggerDB.info(new TraceLogInfo(userSessionId, "Changed application status to " + newStatus, EntityNames.APPLICATION, activeFreqApplication.getId()));
			} catch (Exception e) {
				logger.error("", e);
				loggerDB.error(new TraceLogInfo(userSessionId, "Error changing application status: " + e.getMessage(), EntityNames.APPLICATION, activeFreqApplication.getId()), e);
				FacesUtils.addMessageError(e);
			}
			newStatus = null;
			update(activeFreqApplication.getId(), EDIT_MODE);
		}
	}

	public void update(Long id, int mode) {
		try {
			List<FreqApplication> apps = applicationDao.getFreqApplications(userSessionId, SelectionParams.build("id", id));
			if (apps == null || apps.size() == 0) {
				return;
			}
			detailFreqApplication = (FreqApplication) apps.get(0).clone();
			if (mode == EDIT_MODE) {
				freqApplicationSource.replaceObject(activeFreqApplication, detailFreqApplication);
			} else {
				itemSelection.addNewObjectToList(detailFreqApplication);
			}
			activeFreqApplication = detailFreqApplication;
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo("FreqApplication has been saved.");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}

	}

	public void cancelStatusChange() {
		newStatus = null;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		if (tabName.equalsIgnoreCase("operationsTab")) {
			MbOperationsBottom bean = ManagedBeanWrapper.getManagedBean("MbOperationsBottom");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("traceTab")) {
			MbProcessTrace bean = ManagedBeanWrapper.getManagedBean("MbProcessTrace");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}

	public void loadCurrentTab() {
		loadTab(tabName);
	}

	private void loadTab(String tab) {
		if (tab == null)
			return;
		if (activeFreqApplication == null)
			return;

		if (tab.equalsIgnoreCase("operationsTab")) {
			MbOperationsBottom operationsBean = ManagedBeanWrapper.getManagedBean("MbOperationsBottom");
			operationsBean.clearFilter();
			operationsBean.setApplicationIdFilter(activeFreqApplication.getId());
			operationsBean.searchByOperation();
		} else if (tab.equals("traceTab")) {
			MbProcessTrace traceBean = ManagedBeanWrapper.getManagedBean("MbProcessTrace");
			traceBean.clearBean();
			ProcessTrace filterTrace = new ProcessTrace();
			filterTrace.setEntityType(EntityNames.APPLICATION);
			filterTrace.setObjectId(activeFreqApplication.getId());
			traceBean.setFilter(filterTrace);
			traceBean.search();
		}
	}

	public List<SelectItem> getRejectCodes() {
		List<SelectItem> result = new ArrayList<SelectItem>(getDictUtils().getLov(LovConstants.APPLICATION_REJECT_CODE));
		for (Iterator<SelectItem> i = result.iterator(); i.hasNext(); ) {
			if (i.next().getValue().equals("APRJ0001")) {
				i.remove();
			}
		}
		return result;
	}

	public String viewApp() {
		try {
			MbApplication appBean = ManagedBeanWrapper.getManagedBean("MbApplication");
			appBean.setPageNumber(pageNumber);
			appBean.setRowsNum(rowsNum);
			appBean.setActiveApp(activeFreqApplication);
			// be before
			// getApplicationForView();
			appBean.getApplicationForView();
			appBean.setBackLink(thisBackLink);
			appBean.setModule("FRQ");
			appBean.setKeepState(true);
			FacesUtils.setSessionMapValue(FREQ_FILTER_KEY, filter);
			Menu menu = ManagedBeanWrapper.getManagedBean("menu");
			menu.setKeepState(true);
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return null;
		}
		return "applications|edit";
	}

	public List<SelectItem> getEntityTypes() {
		if (entityTypes == null) {
			entityTypes = getDictUtils().getLov(LovConstants.OPERATIONAL_REQUESTS_ENTITY_TYPES);
		}
		return entityTypes;
	}

	private void setDefaultValues() {
		Calendar today = Calendar.getInstance();
		today.set(Calendar.HOUR, 0);
		today.set(Calendar.MINUTE, 0);
		today.set(Calendar.SECOND, 0);
		freqAppDateFrom = today.getTime();
	}
}
