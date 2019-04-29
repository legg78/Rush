package ru.bpc.sv2.ui.process.monitoring;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.common.CommonWizardStepInfo;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.OperationStat;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbOperTypeSelectionStep;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbOperationsStat")
public class MbOperationsStat extends AbstractBean {
	private OperationDao _operationsDAO = new OperationDao();

	private final DaoDataModel<OperationStat> _processStatSource;

	private final TableRowSelection<OperationStat> _processStatSelection;
	private static final Logger logger = Logger.getLogger("PROCESSES");
	private OperationStat activeOperationStat;

	private Long sessionId;
	private Long sessionFileId;
	
	private static String COMPONENT_ID = "statTable";
	private String tabName;
	private String parentSectionId;

	private boolean groupByStatus;
	private boolean groupByOperType;
	private boolean groupByCurrency;
	private boolean groupByMsgType;
	private boolean groupBySttlType;
	private boolean groupByReversal;
	
	private List<SelectItem> operTypes;
	private List<SelectItem> msgTypes;
	private List<SelectItem> sttlTypes;
	private List<SelectItem> operStatuses;
	
	private OperationStat filter; 
	
	public MbOperationsStat() {
		groupByStatus = true; 
		groupByOperType = true;

		_processStatSource = new DaoDataListAllModel<OperationStat>(logger) {
			@Override
			protected List<OperationStat> loadDaoListData(SelectionParams params) {
				if (searching && (sessionId != null || sessionFileId != null)) {
					setFilters();
					params.setFilters(filters);

					searching = false;
					return _operationsDAO.getOperationStats(userSessionId, params);
				}
				return null;
			}
		};

		_processStatSelection = new TableRowSelection<OperationStat>(null, _processStatSource);
	}

	public DaoDataModel<OperationStat> getStats() {
		return _processStatSource;
	}

	public SimpleSelection getItemSelection() {
		if (activeOperationStat == null && _processStatSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (activeOperationStat != null && _processStatSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(activeOperationStat.getModelId());
			_processStatSelection.setWrappedSelection(selection);
			activeOperationStat = _processStatSelection.getSingleSelection();
		}
		return _processStatSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_processStatSelection.setWrappedSelection(selection);
		activeOperationStat = _processStatSelection.getSingleSelection();
		if (activeOperationStat != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_processStatSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeOperationStat = (OperationStat) _processStatSource.getRowData();
		selection.addKey(activeOperationStat.getModelId());
		_processStatSelection.setWrappedSelection(selection);
		if (activeOperationStat != null) {
			setBeans();
		}
	}
	
	public void setBeans() {
		MbEntriesStat entriesStat = (MbEntriesStat)ManagedBeanWrapper.getManagedBean("MbEntriesStat");
		entriesStat.clear();
		Map<String, Object> params = new HashMap<String, Object>();
        params.put("sessionId", sessionId);
        params.put("sessionFileId", sessionFileId);
		params.put("status", activeOperationStat.getStatus());
		params.put("operType", activeOperationStat.getOperType());
		params.put("msgType", activeOperationStat.getMsgType());
		params.put("sttlType", activeOperationStat.getSttlType());
		params.put("currency", activeOperationStat.getOperCurrency());
		params.put("reversal", activeOperationStat.getReversal());
		entriesStat.setFilter(params);
	}

	public void setFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		if(sessionId != null && sessionFileId != null) {
		    logger.warn("It's correct? Need only one id. [sessionId=" + sessionId + "], [sessionFileId=" + sessionFileId + "]");
        }
		if (sessionId != null) {
			filtersList.add(new Filter("sessionId", sessionId));
		}
		if (sessionFileId != null) {
			filtersList.add(new Filter("sessionFileId", sessionFileId));
		}
		if (getFilter().getOperType() != null && getFilter().getOperType().trim().length() > 0) {
			filtersList.add(new Filter("operType", getFilter().getOperType()));
		}
		if (getFilter().getMsgType() != null && getFilter().getMsgType().trim().length() > 0) {
			filtersList.add(new Filter("msgType", getFilter().getMsgType()));
		}
		if (getFilter().getSttlType() != null && getFilter().getSttlType().trim().length() > 0) {
			filtersList.add(new Filter("sttlType", getFilter().getSttlType()));
		}
		if (getFilter().getStatus() != null && getFilter().getStatus().trim().length() > 0) {
			filtersList.add(new Filter("status", getFilter().getStatus()));
		}
		if (getFilter().getOperCurrency() != null && getFilter().getOperCurrency().trim().length() > 0) {
			filtersList.add(new Filter("operCurrency", getFilter().getOperCurrency()));
		}
		filtersList.add(new Filter("entityType", "ENTTOPER"));

		List<String> groupByResultList = new ArrayList<String>();
		List<String> groupByList = new ArrayList<String>();
		if (groupByOperType) {
			groupByList.add("op.oper_type");
			groupByResultList.add("op.oper_type operType");
		} else {
			groupByResultList.add("null operType");
		}
		if (groupBySttlType) {
			groupByList.add("op.sttl_type");
			groupByResultList.add("op.sttl_type sttlType");
		} else {
			groupByResultList.add("null sttlType");
		}
		if (groupByMsgType) {
			groupByList.add("op.msg_type");
			groupByResultList.add("op.msg_type msgType");
		} else {
			groupByResultList.add("null msgType");
		}
		if (groupByReversal) {
			groupByList.add("op.is_reversal");
			groupByResultList.add("op.is_reversal reversal");
		} else {
			groupByResultList.add("null reversal");
		}
		if (groupByStatus) {
			groupByList.add("op.status");
			groupByResultList.add("op.status status");
		} else {
			groupByResultList.add("null status");
		}
		if (groupByCurrency) {
			groupByList.add("op.oper_currency");
			groupByResultList.add("op.oper_currency operCurrency");
			groupByResultList.add("sum(op.oper_amount) operAmount");
		} else {
			groupByResultList.add("null operCurrency");
			groupByResultList.add("null operAmount");
		}
		filtersList.add(new Filter("groupBy", null, groupByList));
		filtersList.add(new Filter("groupByResult", null, groupByResultList));
		filters = filtersList;
	}

	public void setSessionId(Long sessionId) {
		this.sessionId = sessionId;
	}
	
	public void setSessionFileId(Long sessionFileId) {
		this.sessionFileId = sessionFileId;
	}

	public void manualSearch() {
		search();
		searching = true;
	}

	public void search() {
		_processStatSource.flushCache();
		activeOperationStat = null;
	}

	@Override
	public void clearFilter() {
		sessionId = null;
		sessionFileId = null;
		searching = false;
		clearBeans();
	}
	private void clearBeans() {
		MbEntriesStat entriesStat = (MbEntriesStat)ManagedBeanWrapper.getManagedBean("MbEntriesStat");
		entriesStat.clear();
	}
	
	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}

	public boolean isGroupByStatus() {
		return groupByStatus;
	}

	public void setGroupByStatus(boolean groupByStatus) {
		this.groupByStatus = groupByStatus;
	}

	public boolean isGroupByOperType() {
		return groupByOperType;
	}

	public void setGroupByOperType(boolean groupByOperType) {
		this.groupByOperType = groupByOperType;
	}

	public boolean isGroupByCurrency() {
		return groupByCurrency;
	}

	public void setGroupByCurrency(boolean groupByCurrency) {
		this.groupByCurrency = groupByCurrency;
	}

	public boolean isGroupByMsgType() {
		return groupByMsgType;
	}

	public void setGroupByMsgType(boolean groupByMsgType) {
		this.groupByMsgType = groupByMsgType;
	}

	public boolean isGroupBySttlType() {
		return groupBySttlType;
	}

	public void setGroupBySttlType(boolean groupBySttlType) {
		this.groupBySttlType = groupBySttlType;
	}

	public boolean isGroupByReversal() {
		return groupByReversal;
	}

	public void setGroupByReversal(boolean groupByReversal) {
		this.groupByReversal = groupByReversal;
	}

	public String toOperations() {
		HashMap<String,Object> queueFilter = new HashMap<String,Object>();
		queueFilter.put("sessionId", sessionId);
		queueFilter.put("sessionFileId", sessionFileId);
		if (activeOperationStat != null) {
			if (activeOperationStat.getStatus() != null) {
				queueFilter.put("status", activeOperationStat.getStatus());		
			}
			if (activeOperationStat.getOperType() != null) {
				queueFilter.put("operType", activeOperationStat.getOperType());		
			}
			if (activeOperationStat.getMsgType() != null) {
				queueFilter.put("msgType", activeOperationStat.getMsgType());		
			}
			if (activeOperationStat.getSttlType() != null) {
				queueFilter.put("sttlType", activeOperationStat.getSttlType());		
			}
			if (activeOperationStat.getOperCurrency() != null) {
				queueFilter.put("currency", activeOperationStat.getOperCurrency());		
			}
			if (activeOperationStat.getReversal() != null) {
				queueFilter.put("reversal", activeOperationStat.getReversal());		
			}
		}
		addFilterToQueue("MbOperations", queueFilter);

		Menu mbMenu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		mbMenu.externalSelect("issuing|operations");

		return "issuing|operations";
	}

	public OperationStat getActiveOperationStat() {
		return activeOperationStat;
	}

	public void setActiveOperationStat(OperationStat activeOperationStat) {
		this.activeOperationStat = activeOperationStat;
	}

	public OperationStat getFilter() {
		if (filter == null) {
			filter = new OperationStat();
		}
		return filter;
	}

	public void setFilter(OperationStat filter) {
		this.filter = filter;
	}

	public List<SelectItem> getOperTypes() {
		if (operTypes == null) {
			operTypes = getDictUtils().getLov(LovConstants.OPERATION_TYPE);
		}
		return operTypes;
	}

	public List<SelectItem> getMsgTypes() {
		if (msgTypes == null) {
			msgTypes = getDictUtils().getLov(LovConstants.MESSAGE_TYPES);
		}
		return msgTypes;
	}

	public List<SelectItem> getSttlTypes() {
		if (sttlTypes == null) {
			sttlTypes = getDictUtils().getLov(LovConstants.SETTLEMENT_TYPES);
		}
		return sttlTypes;
	}

	public List<SelectItem> getOperStatuses() {
		if (operStatuses == null) {
			operStatuses = getDictUtils().getLov(LovConstants.OPERATION_STATUSES);
		}
		return operStatuses;
	}

	public void setupOperTypeSelection(){
		CommonWizardStepInfo step = new CommonWizardStepInfo();
		step.setOrder(0);
		step.setSource(MbOperTypeSelectionStep.class.getSimpleName());
		step.setName(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Opr","select_oper_type"));
		List<CommonWizardStepInfo> stepsList = new ArrayList<CommonWizardStepInfo>();
		stepsList.add(step);
		Map<String, Object> context = new HashMap<String, Object>();
		context.put(MbCommonWizard.STEPS, stepsList);
		
		if (sessionFileId != null) {
			context.put(MbOperTypeSelectionStep.OBJECT_ID, sessionFileId);
			context.put(MbOperTypeSelectionStep.ENTITY_TYPE, EntityNames.SESSION_FILE);
		} else if (sessionId != null) {
			context.put(MbOperTypeSelectionStep.OBJECT_ID, sessionId);
			context.put(MbOperTypeSelectionStep.ENTITY_TYPE, EntityNames.SESSION);
		}
		context.put(MbOperTypeSelectionStep.OBJECT_TYPE, EntityNames.OPERATION);
		context.put(MbOperTypeSelectionStep.OBJECT_ID_NEED, false);
		context.put(MbOperTypeSelectionStep.OBJECT_TYPE_STRICT, true);
		
		
		context.put("SESSION_ID", sessionId);
		if (sessionFileId != null) {
			context.put("SESSION_FILE_ID", sessionFileId);
		}
		if (activeOperationStat != null) {
			if (activeOperationStat.getStatus() != null) {
				context.put("OPER_STATUS", activeOperationStat.getStatus());
			}
			if (activeOperationStat.getOperType() != null) {
				context.put("OPER_TYPE", activeOperationStat.getOperType());
			}
			if (activeOperationStat.getMsgType() != null) {
				context.put("MSG_TYPE", activeOperationStat.getMsgType());
			}
			if (activeOperationStat.getSttlType() != null) {
				context.put("STTL_TYPE", activeOperationStat.getSttlType());
			}
			if (activeOperationStat.getOperCurrency() != null) {
				context.put("OPER_CURRENCY", activeOperationStat.getOperCurrency());
			}			
			if (activeOperationStat.getReversal() != null) {
				context.put("REVERSAL", activeOperationStat.getReversal());
			}
		}
		
		MbCommonWizard wizard = ManagedBeanWrapper.getManagedBean(MbCommonWizard.class);
		wizard.init(context);		
	}

}
