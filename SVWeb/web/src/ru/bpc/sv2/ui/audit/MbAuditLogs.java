package ru.bpc.sv2.ui.audit;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;
import org.apache.poi.ss.usermodel.*;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.administrative.roles.Privilege;
import ru.bpc.sv2.administrative.users.User;
import ru.bpc.sv2.audit.AuditTrail;
import ru.bpc.sv2.audit.TrailDetails;
import ru.bpc.sv2.constants.*;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.RolesDao;
import ru.bpc.sv2.process.ProcessSession;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;
import util.servlet.FileServlet;

@ViewScoped
@ManagedBean (name = "MbAuditLogs")
public class MbAuditLogs extends AbstractBean {
	private static final long serialVersionUID = -4765091866217297455L;
	
	private static final Logger logger = Logger.getLogger("AUDIT");

	private static String COMPONENT_ID = "1029:mainTable";

	private CommonDao _commonDao = new CommonDao();
	
	private RolesDao _rolesDao = new RolesDao();

	private AuditTrail _activeTrail;

	private final DaoDataModel<AuditTrail> _logTrailsSource;

	private final TableRowSelection<AuditTrail> _itemSelection;
	private AuditTrail filter;
	private List<Filter> filters;

	private String tabName;
	private String needRerender;
	private List<String> rerenderList;
	private ByteArrayOutputStream outStream;

	public MbAuditLogs() {
		tabName = "det";
		pageLink = "audit|audit_logs";
		_logTrailsSource = new DaoDataModel<AuditTrail>() {
			private static final long serialVersionUID = 8253082450538989094L;

			@Override
			protected AuditTrail[] loadDaoData(SelectionParams params) {
				try {
					if (!isSearching()) {
						return new AuditTrail[0];
					}
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getAuditLogTrails(userSessionId, params);
				} catch (DataAccessException ee) {
					setDataSize(0);
					FacesUtils.addMessageError(ee);
					logger.error("", ee);
				} finally {

				}
				return new AuditTrail[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				try {
					if (!isSearching()) {
						return 0;
					}
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getAuditLogTrailsCount(userSessionId, params);
				} catch (DataAccessException ee) {
					FacesUtils.addMessageError(ee);
					logger.error("", ee);
				} finally {

				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<AuditTrail>(null, _logTrailsSource);

		HttpServletRequest req = RequestContextHolder.getRequest();
		String sectionId = req.getParameter("sectionId");
		String filterId = req.getParameter("filterId");

		if (sectionId != null && filterId != null && sectionId.equals(getSectionId())) {
			selectedSectionFilter = Integer.parseInt(filterId);
			applySectionFilter(selectedSectionFilter);
		}
	}

	public DaoDataModel<AuditTrail> getLogTrails() {
		return _logTrailsSource;
	}

	public AuditTrail getActiveTrail() {
		return _activeTrail;
	}

	public void setActiveTrail(AuditTrail activeTrail) {
		_activeTrail = activeTrail;
	}

	public SimpleSelection getItemSelection() {
		if (_activeTrail == null && _logTrailsSource.getRowCount() > 0) {
			_logTrailsSource.setRowIndex(0);
			SimpleSelection selection = new SimpleSelection();
			_activeTrail = (AuditTrail) _logTrailsSource.getRowData();
			selection.addKey(_activeTrail.getModelId());
			_itemSelection.setWrappedSelection(selection);
			if (_activeTrail != null) {
				setInfo();
			}
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeTrail = _itemSelection.getSingleSelection();
	}
	
	private void setInfo() {
		loadCurrentTab();
	}

	public void search() {
		clearState();
		setSearching(true);
	}

	public void clearState() {
		_activeTrail = null;
		_logTrailsSource.flushCache();
		_itemSelection.clearSelection();
	}

	public void setFilters() {
		getFilter();
		filters = new ArrayList<Filter>();
		if (filter.getId() != null) {
			filters.add(new Filter("id", filter.getId()));
		}
		if (filter.getEntityType() != null && !filter.getEntityType().equals("")) {
			filters.add(new Filter("entityType", filter.getEntityType()));
		}
		if (filter.getStatus() != null && !filter.getStatus().equals("")) {
			filters.add(new Filter("status", filter.getStatus()));
		}
		if (filter.getActionType() != null && !filter.getActionType().equals("")) {
			filters.add(new Filter("actionType", filter.getActionType()));
		}
		if (filter.getActionDateFrom() != null) {
			filters.add(new Filter("actionDateFrom", filter.getActionDateFrom()));
		}
		if (filter.getActionDateTo() != null) {
			filters.add(new Filter("actionDateTo", filter.getActionDateTo()));
		}
		if (filter.getUserId() != null && filter.getUserId().trim().length() != 0) {
			filters.add(new Filter("userId", filter.getUserId().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_")));
		}
		if (filter.getObjectId() != null) {
			filters.add(new Filter("objectId", filter.getObjectId()));
		}
		if (filter.getPrivId() != null) {
			filters.add(new Filter("privId", filter.getPrivId()));
		}
		if (filter.getUserName() != null && filter.getUserName().trim().length() != 0) {
			filters.add(new Filter("userName", filter.getUserName().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_")));
		}
	}

	public AuditTrail getFilter() {
		if (filter == null) {
			filter = new AuditTrail();
		}
		return filter;
	}

	public void setFilter(AuditTrail filter) {
		this.filter = filter;
	}

	public TrailDetails[] getLogDetails() {
		if (_activeTrail == null)
			return new TrailDetails[0];

		return _commonDao.getTrailDetails(userSessionId, _activeTrail.getId());
	}

	public ArrayList<SelectItem> getEntityTypes() {
		return (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.AUDIT_ENTITY_TYPES);
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		needRerender = null;
		this.tabName = tabName;
		loadCurrentTab();
	}

	public void loadCurrentTab() {
		loadTab(tabName);
	}

	private void loadTab(String tab) {
		if (tabName.equalsIgnoreCase("infoTab")) {
			MbInfoUserSession bean = (MbInfoUserSession) ManagedBeanWrapper
					.getManagedBean("MbInfoUserSession");
			bean.clearFilter();
			if(_activeTrail != null){
				bean.initializeInfo(_activeTrail.getSessionId());
			}
		}
	}

	public String getSectionId() {
		return SectionIdConstants.MONITORING_AUDIT_LOG;
	}

	public List<String> getRerenderList() {
		rerenderList = new ArrayList<String>();
		rerenderList.clear();
		if (needRerender != null) {
			rerenderList.add(needRerender);
		}
		rerenderList.add("err_ajax");
		return rerenderList;
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new AuditTrail();
				setFilterForm(filterRec);
				if (searchAutomatically)
					search();
			}
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	@Override
	public void saveSectionFilter() {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper.getManagedBean("filterFactory");

			Map<String, String> filterRec = new HashMap<String, String>();
			filter = getFilter();
			setFilterRec(filterRec);

			sectionFilter = getSectionFilter();
			sectionFilter.setRecs(filterRec);

			factory.saveSectionFilter(sectionFilter, sectionFilterModeEdit);
			selectedSectionFilter = sectionFilter.getId();
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	private void setFilterForm(Map<String, String> filterRec) throws ParseException {
		getFilter();
		filters = new ArrayList<Filter>();
		if (filterRec.get("id") != null) {
			filter.setId(Long.valueOf(filterRec.get("id")));
		}
		if (filterRec.get("actionType") != null) {
			filter.setActionType(filterRec.get("actionType"));
		}
		if (filterRec.get("objectId") != null) {
			filter.setObjectId(Long.valueOf(filterRec.get("objectId")));
		}
		if (filterRec.get("entityType") != null) {
			filter.setEntityType(filterRec.get("entityType"));
		}
		if (filterRec.get("status") != null) {
			filter.setStatus(filterRec.get("status"));
		}
		SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
		if (filterRec.get("actionDateFrom") != null) {
			filter.setActionDateFrom(df.parse(filterRec.get("actionDateFrom")));
		}
		if (filterRec.get("actionDateTo") != null) {
			filter.setActionDateTo(df.parse(filterRec.get("actionDateTo")));
		}
	}

	private void setFilterRec(Map<String, String> filterRec) {
		if (filter.getId() != null) {
			filterRec.put("id", filter.getId().toString());
		}
		if (filter.getActionType() != null) {
			filterRec.put("actionType", filter.getActionType());
		}
		if (filter.getObjectId() != null) {
			filterRec.put("objectId", filter.getObjectId().toString());
		}
		if (filter.getEntityType() != null) {
			filterRec.put("entityType", filter.getEntityType());
		}
		if (filter.getStatus() != null) {
			filterRec.put("status", filter.getStatus());
		}
		SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
		if (filter.getActionDateFrom() != null) {
			filterRec.put("actionDateFrom", df.format(filter.getActionDateFrom()));
		}
		if (filter.getActionDateTo() != null) {
			filterRec.put("actionDateTo", df.format(filter.getActionDateTo()));
		}
	}

	public void clearFilter() {
		filter = null;
		clearBean();
		clearSectionFilter();
		searching = false;
	}

	public void clearBean() {
		curLang = userLang;
		_logTrailsSource.flushCache();
		_itemSelection.clearSelection();
		_activeTrail = null;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public List<SelectItem> getPrivileges() {
		try {
			Privilege[] privs = _rolesDao.getPrivsForCombo(userSessionId);
			List<SelectItem> items = new ArrayList<SelectItem>(privs.length);
			for (Privilege priv: privs) {
				items.add(new SelectItem(priv.getId(), priv.getShortDesc()));
			}
			return items;
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return new ArrayList<SelectItem>(0);
	}
	
	public List<SelectItem> getStatuses() {
		return getDictUtils().getArticles(DictNames.AUDIT_STATUS);
	}
	
	public void initPanel() {
	}
	
	public void selectCurrentUser() {
		MbUserSearchModal userBean = (MbUserSearchModal) ManagedBeanWrapper
				.getManagedBean("MbUserSearchModal");
		User selected = userBean.getActiveUser();
		if (selected != null) {
			getFilter().setUserName(selected.getName());
			getFilter().setUserId(selected.getId().toString());
		}
	}

	public void selectUser() {
		selectCurrentUser();
	}

	public void export() {
		outStream = new ByteArrayOutputStream();
		// get Audit log list
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		params.setRowIndexEnd(-1);
		AuditTrail[] auditTrails = _commonDao.getAuditLogTrailsFull(userSessionId, params);
		List<AuditTrail> auditLogList = Arrays.asList(auditTrails);
		exportXLS(auditLogList);
		generateFileByServlet();
	}

	public void generateFileByServlet() {
		if (outStream == null) return;

		byte[] reportContent = outStream.toByteArray();
		try {
			outStream.close();
		} catch (IOException ignored) {
		}

		HttpServletRequest req = RequestContextHolder.getRequest();
		HttpSession session = req.getSession();
		session.setAttribute(FileServlet.FILE_SERVLET_CONTENT_TYPE, "application/x-download");
		session.setAttribute(FileServlet.FILE_SERVLET_FILE_CONTENT, reportContent);
	}

	public String getReportName() {
		Date today = new Date();
		SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("yyyyMMdd-HHmmss");
		String date = DATE_FORMAT.format(today);
		return "audit_log_" + date + ".xls";
	}

	private void exportXLS(final List<AuditTrail> auditLogList) {
		try {
			final UserSession session = (UserSession) ManagedBeanWrapper.getManagedBean("usession");
			final ExportUtils ex = new ExportUtils() {

				@Override
				public void createHeadRow() {
					Row rowhead = sheet.createRow((short) 0);
					rowhead.createCell(0).setCellValue("Privilege");
					rowhead.createCell(1).setCellValue("Action date");
					rowhead.createCell(2).setCellValue("Entity type");
					rowhead.createCell(3).setCellValue("Object ID");
					rowhead.createCell(4).setCellValue("User");
					rowhead.createCell(5).setCellValue("Status");

					rowhead.createCell(6).setCellValue("User Name");
					rowhead.createCell(7).setCellValue("Start Time");
					rowhead.createCell(8).setCellValue("End time");
					rowhead.createCell(9).setCellValue("IP address");


					//Details
					rowhead.createCell(10).setCellValue("Column name");
					rowhead.createCell(11).setCellValue("Data type");
					rowhead.createCell(12).setCellValue("Old value");
					rowhead.createCell(13).setCellValue("New value");

					sheet.setColumnWidth(0, 20 * 256);
				}

				@Override
				public void createRows() {
					int i = 1;
					TrailDetails trailDetails;
					ProcessSession processSession;

					for (AuditTrail auditTrail : auditLogList) {
						Row row = sheet.createRow(i++);
						row.createCell(0).setCellValue(auditTrail.getPrivName());
						fillCellDate(row.createCell(1), auditTrail.getActionDate(), session.getFullDatePatternSeconds(), session.getCurrentLocale());
						row.createCell(2).setCellValue(auditTrail.getEntityType());
						row.createCell(3).setCellValue(auditTrail.getObjectId() == null ? "" : auditTrail.getObjectId().toString());
						row.createCell(4).setCellValue(auditTrail.getUserName());
						row.createCell(5).setCellValue(auditTrail.getStatus());

						processSession = auditTrail.getProcessSession();
						if (processSession != null){
							row.createCell(6).setCellValue(processSession.getUserName());
							fillCellDate(row.createCell(7), processSession.getStartDate(), session.getFullDatePatternSeconds(), session.getCurrentLocale());
							fillCellDate(row.createCell(8), processSession.getEndDate(), session.getFullDatePatternSeconds(), session.getCurrentLocale());
							row.createCell(9).setCellValue(processSession.getAddress());
						}
						trailDetails = auditTrail.getTrailDetails();
						if(trailDetails != null) {
							row.createCell(10).setCellValue(trailDetails.getColumnName());
							row.createCell(11).setCellValue(getDictUtils().getArticles().get(trailDetails.getDataType()));

							if (trailDetails.isChar()) {
								row.createCell(12).setCellValue(trailDetails.getOldValueV());
								row.createCell(13).setCellValue(trailDetails.getNewValueV());
							} else if (trailDetails.isNumber()) {
								row.createCell(12).setCellValue(trailDetails.getOldValueN() != null ? trailDetails.getOldValueN().toString() : null);
								row.createCell(13).setCellValue(trailDetails.getNewValueN() != null ? trailDetails.getNewValueN().toString() : null);
							} else {
								fillCellDate(row.createCell(12), trailDetails.getOldValueD(), session.getFullDatePatternSeconds(), session.getCurrentLocale());
								fillCellDate(row.createCell(13), trailDetails.getNewValueD(), session.getFullDatePatternSeconds(), session.getCurrentLocale());
							}
						}
					}
				}
			};
			ex.exportXLS(outStream);
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
	}
}
