package ru.bpc.sv2.ui.ps;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.common.ParticipantTableColumn;
import ru.bpc.sv2.common.TableColumn;
import ru.bpc.sv2.configuration.KeyValuePair;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.enums.RejectFieldType;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.RejectDao;
import ru.bpc.sv2.ps.McRejectCode;
import ru.bpc.sv2.ps.RejectOperation;
import ru.bpc.sv2.ps.VisaRejectCode;
import ru.bpc.sv2.ps.filters.RejectFilter;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean(name = "MbReject")
public class MbReject extends AbstractBean {
	private static final long serialVersionUID = 9180917082872879256L;
	private static Logger logger = Logger.getLogger("OPER_RPOCESSING");
	private static final int GEN_TAB = 0;
	private static final int OPER_TAB = 1;
	private static final int PART_TAB = 2;
	private static final int FIN_TAB = 3;

	private int tab = 0;

	private String searchTabName;
	private RejectDao rejectDao = new RejectDao();

	private RejectFilter filter;
	private final DaoDataModel<RejectOperation> messageSource;

	private RejectOperation activeItem;
	private final TableRowSelection<RejectOperation> itemSelection;

	private List<VisaRejectCode> visaRejectCodes;
	private List<McRejectCode> mcRejectCodes;

	private List<TableColumn> origOperProps;
	private List<ParticipantTableColumn> participantProps;
	private List<TableColumn> finMesProps;
	private List<TableColumn> genProps;
	private List<SelectItem> allUsers;

	private TableColumn selProp = new TableColumn();

	private String action;
	private String module;
	private SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");

	private String groupId;

	public String getGroupId() {
		return groupId;
	}

	public void setGroupId(String groupId) {
		this.groupId = groupId;
	}

	public String getModule() {
		return module;
	}

	public void setModule(String module) {
		this.module = module;
	}

	public String getAction() {
		return action;
	}

	public void setAction(String action) {
		this.action = action;
	}

	public void executeAction() {
		if (action != null) {
			rejectDao.executeAction(userSessionId, activeItem.getOrigId(), action);
			action = null;
		}
	}

	public boolean isAdmin() {
		String name = getUserName();
		return name.equalsIgnoreCase("ADMIN");
	}

	public void assignUser() {
		rejectDao.assignUser(module, userSessionId, activeItem.getId(), activeItem.getAssignedUserId());
	}

	public void saveProperty() throws Exception {
		if (tab == GEN_TAB) {
			setActiveItemFields();
		}
		if (selProp instanceof ParticipantTableColumn) {
			rejectDao.updateParticipantField(module, userSessionId, (ParticipantTableColumn) selProp);
		} else {
			rejectDao.updateField(module, userSessionId, selProp, RejectFieldType.values()[tab]);
		}
	}

	public void setTab(int tab) {
		this.tab = tab;
	}

	public MbReject() {
		pageLink = "ps|rejects";
		messageSource = new DaoDataModel<RejectOperation>() {
			private static final long serialVersionUID = 6886825197574225937L;

			@Override
			protected RejectOperation[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new RejectOperation[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return rejectDao.getRejectOperations(module, userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new RejectOperation[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return (int) rejectDao.getRejectOperationsCount(module, userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		itemSelection = new TableRowSelection<RejectOperation>(null, messageSource);
	}

	public List<SelectItem> getGroups() {
		if (activeItem == null) {
			return null;
		}
		List<KeyValuePair> list = rejectDao.getGroups(userSessionId, activeItem.getOrigId(), curLang);
		if (list != null && !list.isEmpty()) {
			List<SelectItem> result = new ArrayList<SelectItem>();
			for (KeyValuePair kvp : list) {
				result.add(new SelectItem(kvp.getKey(), kvp.getKey() + "-" + kvp.getValue()));
			}
			groupId = list.get(0).getKey();
			return result;
		}
		return null;
	}

	public List<SelectItem> getGroupUsers() {
		if (groupId == null) {
			return null;
		}
		List<KeyValuePair> list = rejectDao.getGroupUsers(userSessionId, Long.valueOf(groupId), curLang);
		List<SelectItem> result = new ArrayList<SelectItem>();
		for (KeyValuePair kvp : list) {
			result.add(new SelectItem(kvp.getKey(), kvp.getKey() + "-" + kvp.getValue()));
		}
		return result;
	}

	public List<SelectItem> getAllUsers() {
		if (allUsers == null) {
			List<KeyValuePair> list = rejectDao.getAllUsers(userSessionId, curLang);
			allUsers = new ArrayList<SelectItem>();
			for (KeyValuePair kvp : list) {
				allUsers.add(new SelectItem(kvp.getKey(), kvp.getKey() + "-" + kvp.getValue()));
			}
		}
		return allUsers;
	}

	public List<VisaRejectCode> getVisaRejectCodes() {
		return visaRejectCodes;
	}

	public List<McRejectCode> getMcRejectCodes() {
		return mcRejectCodes;
	}

	public void init() {
		setDefaultValues();
	}

	private void setFilters() {
		RejectFilter rejectFilter = getFilter();
		filters = new ArrayList<Filter>();
		if (rejectFilter.getId() != null) {
			filters.add(new Filter("id", rejectFilter.getId()));
		}
		if (rejectFilter.getArn() != null && rejectFilter.getArn().trim().length() > 0) {
			filters.add(new Filter("arn", rejectFilter.getArn()));
		}
		if (rejectFilter.getScheme() != null && rejectFilter.getScheme().trim().length() > 0) {
			filters.add(new Filter("scheme", rejectFilter.getScheme()));
		}
		if (rejectFilter.getAssigned() != null && rejectFilter.getAssigned().trim().length() > 0) {
			filters.add(new Filter("assigned", rejectFilter.getAssigned()));
		}
		if (rejectFilter.getPan() != null && rejectFilter.getPan().trim().length() > 0) {
			filters.add(new Filter("pan", rejectFilter.getPan()));
		}
		if (rejectFilter.getCode() != null && !rejectFilter.getCode().trim().isEmpty()) {
			filters.add(new Filter("code", rejectFilter.getCode()));
		}
		if (rejectFilter.getOperType() != null && !rejectFilter.getOperType().trim().isEmpty()) {
			filters.add(new Filter("operType", rejectFilter.getOperType()));
		}
		if (rejectFilter.getResolution() != null && !rejectFilter.getResolution().trim().isEmpty()) {
			filters.add(new Filter("resolution", rejectFilter.getResolution()));
		}
		if (rejectFilter.getStatus() != null && !rejectFilter.getStatus().trim().isEmpty()) {
			filters.add(new Filter("status", rejectFilter.getStatus()));
		}
		if (rejectFilter.getDstNetwork() != null) {
			filters.add(new Filter("dstNetwork", rejectFilter.getDstNetwork()));
		}
		if (rejectFilter.getOrigNetwork() != null) {
			filters.add(new Filter("origNetwork", rejectFilter.getOrigNetwork()));
		}
		if (rejectFilter.getProcessDate() != null) {
			filters.add(new Filter("processDate", rejectFilter.getProcessDate()));
		}
		if (rejectFilter.getResolutionDate() != null) {
			filters.add(new Filter("resolutionDate", rejectFilter.getResolutionDate()));
		}
		if (rejectFilter.getType() != null && !rejectFilter.getType().trim().isEmpty()) {
			filters.add(new Filter("type", rejectFilter.getType()));
		}
		if (!isAdmin()) {
			UserSession usession = (UserSession) ManagedBeanWrapper.getManagedBean("usession");
			filters.add(new Filter("assigned", usession.getUser().getId()));
		}
	}

	public List<TableColumn> getGenProps() {
		if (genProps == null) {
			genProps = new ArrayList<TableColumn>();
			genProps.add(new TableColumn("id"));
			genProps.add(new TableColumn("original_id"));
			genProps.add(new TableColumn("reject_type"));
			genProps.add(new TableColumn("process_date", "date"));
			genProps.add(new TableColumn("originator_network"));
			genProps.add(new TableColumn("destination_network"));
			genProps.add(new TableColumn("arn"));
			genProps.add(new TableColumn("assigned"));
			genProps.add(new TableColumn("reject_code"));
			genProps.add(new TableColumn("status"));
			genProps.add(new TableColumn("scheme"));
			genProps.add(new TableColumn("operation_type"));
			genProps.add(new TableColumn("card_number", false));
			genProps.add(new TableColumn("resolution_mode"));
			genProps.add(new TableColumn("resolution_date", "date"));
		}
		if (activeItem != null) {
			if (activeItem.getId() != null) {
				genProps.get(0).setValue(String.valueOf(activeItem.getId()));
			} else {
				genProps.get(0).setValue(null);
			}
			if (activeItem.getOrigId() != null) {
				genProps.get(1).setValue(String.valueOf(activeItem.getOrigId()));
			} else {
				genProps.get(1).setValue(null);
			}
			if (activeItem.getType() != null) {
				genProps.get(2).setValue(String.valueOf(activeItem.getType()));
			} else {
				genProps.get(2).setValue(null);
			}
			if (activeItem.getProcessDate() != null) {
				genProps.get(3).setValue(sdf.format(activeItem.getProcessDate()));
			} else {
				genProps.get(3).setValue(null);
			}
			if (activeItem.getOrigNetwork() != null) {
				genProps.get(4).setValue(String.valueOf(activeItem.getOrigNetwork()));
			} else {
				genProps.get(4).setValue(null);
			}
			if (activeItem.getDstNetwork() != null) {
				genProps.get(5).setValue(String.valueOf(activeItem.getDstNetwork()));
			} else {
				genProps.get(5).setValue(null);
			}
			genProps.get(6).setValue(activeItem.getArn());
			genProps.get(7).setValue(activeItem.getAssignedUserId());
			genProps.get(8).setValue(activeItem.getCode());
			genProps.get(9).setValue(activeItem.getStatus());
			genProps.get(10).setValue(activeItem.getScheme());
			genProps.get(11).setValue(activeItem.getOperType());
			genProps.get(12).setValue(activeItem.getPanMask());
			genProps.get(13).setValue(activeItem.getResolution());
			if (activeItem.getResolutionDate() != null) {
				genProps.get(14).setValue(sdf.format(activeItem.getResolutionDate()));
			}
			for (TableColumn tc : genProps) {
				tc.setId(activeItem.getId());
			}
		}
		return genProps;
	}

	public void setActiveItemFields() throws Exception {
		TableColumn tc = genProps.get(1);
		if (tc != null && tc.getValue() != null && !tc.getValue().isEmpty()) {
			activeItem.setOrigId(Long.valueOf(tc.getValue()));
		}
		activeItem.setType(genProps.get(2).getValue());
		tc = genProps.get(3);
		if (tc != null && tc.getValue() != null && !tc.getValue().isEmpty()) {
			activeItem.setProcessDate(sdf.parse(tc.getValue()));
		}
		tc = genProps.get(4);
		if (tc != null && tc.getValue() != null && !tc.getValue().isEmpty()) {
			activeItem.setOrigNetwork(tc.getValue());
		}
		tc = genProps.get(5);
		if (tc != null && tc.getValue() != null && !tc.getValue().isEmpty()) {
			activeItem.setDstNetwork(tc.getValue());
		}
		activeItem.setArn(genProps.get(6).getValue());
		activeItem.setAssignedUserId(genProps.get(7).getValue());
		activeItem.setCode(genProps.get(8).getValue());
		activeItem.setStatus(genProps.get(9).getValue());
		activeItem.setScheme(genProps.get(10).getValue());
		activeItem.setOperType(genProps.get(11).getValue());
		activeItem.setResolution(genProps.get(13).getValue());
		tc = genProps.get(14);
		if (tc != null && tc.getValue() != null && !tc.getValue().isEmpty()) {
			activeItem.setResolutionDate(sdf.parse(tc.getValue()));
		}
	}

	public void setSelProp(String prop) {
		List list = genProps;
		switch (tab) {
			case OPER_TAB:
				list = origOperProps;
				break;
			case FIN_TAB:
				list = finMesProps;
				break;
			case PART_TAB:
				list = participantProps;
				break;
		}
		if (list != null) {
			for (Object obj : list) {
				TableColumn pr = (TableColumn) obj;
				if (pr.getColumn().equals(prop)) {
					selProp = pr;
					return;
				}
			}
		}
	}

	public TableColumn getProp() {
		return selProp;
	}

	public boolean isDate() {
		if (selProp != null) {
			return selProp.getValue().matches("");
		}
		return false;
	}

	public SimpleSelection getItemSelection() {
		if (activeItem != null && messageSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(activeItem.getModelId());
			itemSelection.setWrappedSelection(selection);
		}
		return itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		itemSelection.setWrappedSelection(selection);
		activeItem = itemSelection.getSingleSelection();
		if (activeItem != null) {
			origOperProps = rejectDao.getFields(module, userSessionId, activeItem.getOrigId(),
					RejectFieldType.ORIG_OPER);
			finMesProps = rejectDao.getFields(module, userSessionId, activeItem.getOrigId(),
					RejectFieldType.FIN_MESSAGE);
			participantProps = rejectDao.getParticipantFields(module, userSessionId, activeItem.getOrigId());
			if (module.equalsIgnoreCase("VISA")) {
				visaRejectCodes = rejectDao.getVisaRejectCodes(userSessionId, activeItem.getId());
			}
			if (module.equalsIgnoreCase("MC")) {
				mcRejectCodes = rejectDao.getMcRejectCodes(userSessionId, activeItem.getId());
			}
		}
	}

	public List<TableColumn> getOrigOperProps() {
		return origOperProps;
	}

	public List<TableColumn> getFinMesProps() {
		return finMesProps;
	}

	public List<ParticipantTableColumn> getParticipantProps() {
		return participantProps;
	}

	public void search() {
		setSearching(true);
		clearBean();
	}

	private void clearBean() {
		messageSource.flushCache();
		itemSelection.clearSelection();
		activeItem = null;
		origOperProps = null;
		participantProps = null;
		finMesProps = null;
		genProps = null;
		selProp = null;
	}

	public void clearFilter() {
		setSearching(false);
		clearBean();
		setDefaultValues();
	}

	public String getSearchTabName() {
		return searchTabName;
	}

	public void setSearchTabName(String searchTabName) {
		this.searchTabName = searchTabName;
	}

	public String getSectionId() {
		return SectionIdConstants.ISSUING_CREDIT_DEBT;
	}

	public boolean getSearching() {
		return searching;
	}

	public void setFilter(RejectFilter filter) {
		this.filter = filter;
	}

	public RejectFilter getFilter() {
		if (filter == null) {
			filter = new RejectFilter();
		}
		return filter;
	}

	public DaoDataModel<RejectOperation> getItems() {
		return messageSource;
	}

	public RejectOperation getActiveItem() {
		return activeItem;
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}

	public int getRowsNum() {
		return rowsNum;
	}

	public String getComponentId() {
		return "2336:rejects";
	}


	private void setDefaultValues() {
		filter = new RejectFilter();
	}
}
