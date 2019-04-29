package ru.bpc.sv2.ui.operations;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.atm.AtmCollection;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.ModuleNames;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.invocation.SortElement.Direction;
import ru.bpc.sv2.logic.AtmDao;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.EntityOperType;
import ru.bpc.sv2.operations.Operation;
import ru.bpc.sv2.operations.OperationPrivConstants;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.operations.constants.OperationsConstants;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.context.ContextType;
import ru.bpc.sv2.ui.context.ContextTypeFactory;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.*;

@ViewScoped
@ManagedBean (name = "MbOperationsBottom")
public class MbOperationsBottom extends AbstractBean {
	private static final long serialVersionUID = -9000304736870790606L;

	private OperationDao _operationDao = new OperationDao();

	private AtmDao atmDao = new AtmDao();
	
	private Operation operationFilter;
	private Participant participantFilter;
	private Long applicationIdFilter;
	private ru.bpc.sv2.operations.incoming.Operation adjustmentFilter;
	private Date hostDateFrom;
	private Date hostDateTo;
	private HashMap<String, EntityOperType> operTypes;

	private final DaoDataModel<Operation> _operationSource;
	private final TableRowSelection<Operation> _itemSelection;
	private Operation _activeOperation;
	private String displayFormat;

	private ru.bpc.sv2.operations.incoming.Operation newAdjustment;

	private static final Logger logger = Logger.getLogger("OPER_PROCESSING");

	private boolean disableOperType;

	private String operTypeEntityType;
	private Date operDateTo;
	private Date operDateFrom;
	
	private String operType;
	private String backLink;
	private String searchType;
	
	private static final String COMPONENT_ID = "operationsTable";
	private String tabName;
	private String searchTabName;
	private String parentSectionId;
	
	private List<SelectItem> collections;
	private AtmCollection[] collectionSource;
	private int selectedCollectionIdx;
	
	private ContextType ctxType;
	private String ctxItemEntityType;
	private Map<String, Object> paramMap;
	
	private String objectType;

	private BigDecimal[] idTab;

	public MbOperationsBottom() {
		displayFormat = "MMMM dd, yyyy";
		operationFilter = new Operation();
		rowsNum = 30;
		operTypeEntityType = beanEntityType = EntityNames.ACCOUNT;
		
		_operationSource = new DaoDataListModel<Operation>(logger) {
			private static final long serialVersionUID = -1514377742409280830L;

			@Override
			protected List<Operation> loadDaoListData(SelectionParams params) {
				if (searching) {
					try {
						setFilters();

						if (isSearchByParticipant()) {
							getParamMap().put("param_tab", filters.toArray(new Filter[filters.size()]));
							params.setFilters(filters.toArray(new Filter[filters.size()]));
							if (participantFilter.getParticipantType() != null) {
								paramMap.put("oper_id_tab", idTab);
								return _operationDao.getOperationCursor(userSessionId, params, paramMap, OperationPrivConstants.VIEW_OPERATION);
							} else {
								return _operationDao.getOperationAccCursor(userSessionId, params, paramMap, OperationPrivConstants.VIEW_OPERATION);
							}
						}
						params.setPrivilege(OperationPrivConstants.VIEW_OPERATION_TAB);
						return _operationDao.getOperations(userSessionId, params, curLang);
					} catch (Exception e) {
						setDataSize(0);
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				}
				return new ArrayList<Operation>();
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (searching) {
					try {
						setFilters();
						params.setFilters(filters.toArray(new Filter[filters.size()]));
						if (isSearchByParticipant()) {
							int threshold = 300;
							getParamMap().put("param_tab", filters.toArray(new Filter[filters.size()]));
							params.setThreshold(threshold);
							if (participantFilter.getParticipantType() != null) {
								int count = _operationDao.getOperationCursorCount(userSessionId, paramMap, OperationPrivConstants.VIEW_OPERATION);
								idTab  = (BigDecimal[])paramMap.get("oper_id_tab");
								return count;
							} else {
								return _operationDao.getOperationAccCursorCount(userSessionId, paramMap, OperationPrivConstants.VIEW_OPERATION);
							}
						}
						params.setPrivilege(OperationPrivConstants.VIEW_OPERATION_TAB);
						return _operationDao.getOperationsCount(userSessionId, params);
					} catch (Exception e) {
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Operation>(null, _operationSource);
	}

	public DaoDataModel<Operation> getOperations() {
		return _operationSource;
	}

	public Operation getActiveOperation() {
		return _activeOperation;
	}

	public void setActiveOperation(Operation activeOperation) {
		_activeOperation = activeOperation;
		if (activeOperation != null) {
			setBeans();
		}
	}

	public SimpleSelection getItemSelection() {
		setFirstRowActive();
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeOperation = _itemSelection.getSingleSelection();
		if (_activeOperation != null) {
			setBeans();
		}

	}

	public void setFirstRowActive() {
		if (_activeOperation == null && _operationSource.getRowCount() > 0) {
			_operationSource.setRowIndex(0);
			SimpleSelection selection = new SimpleSelection();
			_activeOperation = (Operation) _operationSource.getRowData();
			if (_activeOperation != null) {
				selection.addKey(_activeOperation.getModelId());
				setBeans();
			}
			_itemSelection.setWrappedSelection(selection);
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
		MbEntriesForOperation entryBean = ManagedBeanWrapper.getManagedBean("MbEntriesForOperation");
		entryBean.clearBean();
		if (_activeOperation != null) {
			entryBean.setOperationId(_activeOperation.getId());
		}
		entryBean.setEntityType(EntityNames.OPERATION);
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void searchByOperation() {
		searchType = EntityNames.OPERATION;
		search();
	}

	public void searchByParticipant() {
		searchType = EntityNames.PARTICIPANT;
		search();
	}

	private boolean isSearchByParticipant() {
		return EntityNames.PARTICIPANT.equals(searchType);
	}

	public void clearFilter() {
		clearState();
		getParamMap().clear();
		curLang = userLang;
		operationFilter = new Operation();
		participantFilter = new Participant();

		operDateFrom = null;
		operDateTo = null;
		searching = false;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeOperation = null;
		_operationSource.flushCache();
		
		disableOperType = false;
		selectedCollectionIdx = 0;
		collections = null;
		collectionSource = null;
//		loadedTabs.clear();
	}

	public void fullCleanBean() {
		clearFilter();
		adjustmentFilter = null;
	}
	
	public void setFilters() {
		if (isSearchByParticipant()) {
			setFiltersParticipant(true);
		} else {
			setFiltersOperation();
		}
	}
	
	public void setFiltersOperation() {
		getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (applicationIdFilter != null) {
			filters.add(new Filter("applId", applicationIdFilter));
		}
		if (operationFilter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("operId");
			paramFilter.setValue(operationFilter.getId().toString());
			filters.add(paramFilter);
		}
		
		if (operationFilter.getOperType() != null && !"".equals(operationFilter.getOperType())){
			paramFilter = new Filter();
			paramFilter.setElement("operationType");
			paramFilter.setValue(operationFilter.getOperType());
			filters.add(paramFilter);
		}
		setDateFilters();
		setFiltersParticipant(false);
	}

	private void setDateFilters() {
		UserSession usession = ManagedBeanWrapper.getManagedBean("usession");
		CommonUtils utils = ManagedBeanWrapper.getManagedBean("CommonUtils");
		
		String dbDateFormat = usession.getDatePattern();
		SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
		df.setTimeZone(utils.getTimeZone());
		
		Filter paramFilter;
		if (hostDateFrom != null) {
			paramFilter = new Filter();
			paramFilter.setElement("HOST_DATE_FROM");
			paramFilter.setValue(hostDateFrom);
			filters.add(paramFilter);
		}
		
		if (hostDateTo != null) {
			paramFilter = new Filter();
			paramFilter.setElement("HOST_DATE_TILL");
			paramFilter.setValue(hostDateTo);
			filters.add(paramFilter);
		}

		if (operDateFrom != null) {
			paramFilter = new Filter();
			paramFilter.setElement("operDateFrom");
			paramFilter.setValue(String.valueOf(df.format(operDateFrom)));
			filters.add(paramFilter);
			if (hostDateFrom == null) {
				paramFilter = new Filter();
				paramFilter.setElement("hostDateFrom");
				paramFilter.setValue(String.valueOf(df.format(new Date(operDateFrom.getTime()-24*3600*1000))));
				filters.add(paramFilter);
			}
		}

		if (operDateTo != null) {
			paramFilter = new Filter();
			paramFilter.setElement("operDateTo");
			paramFilter.setValue(String.valueOf(df.format(operDateTo)));
			filters.add(paramFilter);
			if (hostDateTo == null) {
				paramFilter = new Filter();
				paramFilter.setElement("hostDateTo");
				paramFilter.setValue(String.valueOf(df.format(new Date(operDateTo.getTime()+24*3600*1000))));
				filters.add(paramFilter);
			}
		}
	}
	public void setFiltersParticipant(boolean clearFilters) {
		getParticipantFilter();
		
		Filter paramFilter;
		if (clearFilters) {
			filters = new ArrayList<Filter>();
			paramFilter = new Filter("lang", userLang);
			filters.add(paramFilter);
			setDateFilters();
		}
		
		if (searchTabName != null && searchTabName.trim().length() > 0) {
			getParamMap().put("tab_name", searchTabName);
		}
		
		if (participantFilter.getCustomerId() != null ) {
			filters.add(new Filter("participantCustomerId", participantFilter.getCustomerId()));
		}
		
		if (participantFilter.getCardMask() != null &&
				participantFilter.getCardMask().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("cardMask");
			paramFilter.setCondition("=");
			paramFilter.setValue(participantFilter.getCardMask().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			if (((String) paramFilter.getValue()).contains("%") || participantFilter.getCardMask().contains("?")) {
				paramFilter.setCondition("like");
			}
			filters.add(paramFilter);
		}

		filters.add(new Filter("OPER_ID", participantFilter.getOperId())); // always add OPER_ID for filter limitation (CORE-19397)

		if (participantFilter.getCardId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("CARD_ID");
			paramFilter.setValue(participantFilter.getCardId());
			filters.add(paramFilter);
		}
		if (participantFilter.getAccountId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("ACCOUNT_ID");
			paramFilter.setValue(participantFilter.getAccountId());
			filters.add(paramFilter);
		}
		if (participantFilter.getAccountNumber() != null &&
				participantFilter.getAccountNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("accountNumber");
			paramFilter.setCondition("=");
			paramFilter.setValue(participantFilter.getAccountNumber().trim()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			if (((String) paramFilter.getValue()).contains("%") || participantFilter.getAccountNumber().contains("?")) {
				paramFilter.setCondition("like");
			}
			filters.add(paramFilter);
		}
		if (participantFilter.getParticipantType() != null) {
			filters.add(new Filter("PARTICIPANT_MODE",participantFilter.getParticipantType()));
		}
		if (participantFilter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("INST_ID");
			paramFilter.setValue(participantFilter.getInstId());
			filters.add(paramFilter);
		}
		if (participantFilter.getTerminalId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("terminalId");
			paramFilter.setValue(participantFilter.getTerminalId());
			filters.add(paramFilter);
		}
	}

	public void resetBean() {
	}

	public Operation getFilter() {
		if (operationFilter == null) {
			operationFilter = new Operation();
		}
		return operationFilter;
	}

	public void setFilter(Operation operationFilter) {
		this.operationFilter = operationFilter;
	}

	public Participant getParticipantFilter() {
		if (participantFilter == null) {
			participantFilter = new Participant();
		}
		return participantFilter;
	}

	public void setParticipantFilter(Participant participantFilter) {
		this.participantFilter = participantFilter;
	}

	public void add() {
	}

	public void edit() {
	}

	public void save() {
	}

	public void delete() {
	}

	public void close() {

	}

	public ArrayList<SelectItem> getAllAccountTypes() {
		return getDictUtils().getArticles(DictNames.ACCOUNT_TYPE, true, false);
	}

	public Date getHostDateFrom() {
		if (hostDateFrom == null){
			hostDateFrom = new Date();
			int month = hostDateFrom.getMonth() - 1;
			if (month < 0){
				hostDateFrom.setMonth(11);
				hostDateFrom.setYear(hostDateFrom.getYear() - 1);
			}else{
				hostDateFrom.setMonth(month);
			}
			hostDateFrom.setHours(0);;
			hostDateFrom.setMinutes(0);
			hostDateFrom.setSeconds(0);
		}	
		return hostDateFrom;
	}

	public void setHostDateFrom(Date hostDateFrom) {
		this.hostDateFrom = hostDateFrom;
	}

	public Date getHostDateTo() {
		return hostDateTo;
	}

	public void setHostDateTo(Date hostDateTo) {
		this.hostDateTo = hostDateTo;
	}

	public String getDisplayFormat() {
		return displayFormat;
	}

	public void setDisplayFormat(String displayFormat) {
		this.displayFormat = displayFormat;
	}

	public void addAdjustment() {
		ru.bpc.sv2.operations.incoming.Operation filter = getAdjustmentFilter();
		newAdjustment = new ru.bpc.sv2.operations.incoming.Operation();
		newAdjustment.setMsgType(OperationsConstants.MESSAGE_TYPE_PRESENTMENT);
		newAdjustment.setOperationDate(new Date());
		newAdjustment.setSourceHostDate(new Date());
		newAdjustment.setAccountNumber(filter.getAccountNumber());
		newAdjustment.setAccountId(filter.getAccountId());
		newAdjustment.setAcqInstId(filter.getAcqInstId());
		newAdjustment.setIssInstId(filter.getAcqInstId());
		newAdjustment.setSplitHash(filter.getSplitHash());
		newAdjustment.setOperationCurrency(filter.getOperationCurrency());
		newAdjustment.setParticipantType(getParticipantFilter().getParticipantType());
		newAdjustment.setSessionId(userSessionId);
		newAdjustment.setStatus(OperationsConstants.OPERATION_STATUS_PROCESS_READY);
		newAdjustment.setSttlType(OperationsConstants.SETTLEMENT_INTERNAL_INTRAINST);
		operTypeEntityType = beanEntityType;
		curMode = NEW_MODE;
	}

	public void saveAdjustment() {
		try {
			if (isNewMode()) {
				_operationDao.addAdjusment(userSessionId, newAdjustment);
			}
			_operationSource.flushCache();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancelAdjustment() {
		curMode = VIEW_MODE;
	}

	public ru.bpc.sv2.operations.incoming.Operation getNewAdjustment() {
		if (newAdjustment == null) {
			newAdjustment = new ru.bpc.sv2.operations.incoming.Operation();
		}
		return newAdjustment;
	}

	public void setNewAdjustment(ru.bpc.sv2.operations.incoming.Operation newAdjustment) {
		this.newAdjustment = newAdjustment;
	}

	public ArrayList<SelectItem> getOperationTypesAdjustment() {
		ArrayList<SelectItem> items;
		operTypes = new HashMap<String, EntityOperType>();
		
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(curLang);
		filters[1] = new Filter();
		filters[1].setElement("entityType");
		filters[1].setValue(operTypeEntityType);
		
		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(Integer.MAX_VALUE);
		params.setFilters(filters);
		
		try {
			EntityOperType[] types = _operationDao.getEntityOperTypes(userSessionId, params);
			items = new ArrayList<SelectItem>(types.length);
			for (EntityOperType type: types) {
				items.add(new SelectItem(type.getOperType(), getDictUtils().getAllArticlesDescByLang().get(curLang).get(type.getOperType())));
				operTypes.put(type.getOperType(), type);
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage() != null && !e.getMessage().contains(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR)) {
				FacesUtils.addMessageError(e);
			}
			return new ArrayList<SelectItem>(0);
		}
		
		return items;
	}

	public List<SelectItem> getOperationReasons() {
		if (getNewAdjustment().getOperType() != null && operTypes != null 
				&& operTypes.get(newAdjustment.getOperType()) != null
				&& operTypes.get(newAdjustment.getOperType()).getReasonLovId() != null) {
			return getDictUtils().getLov(operTypes.get(newAdjustment.getOperType()).getReasonLovId());
		}
		return new ArrayList<SelectItem>(0);
	}
	
	public boolean isOperReasonNeeded() {
		return getNewAdjustment().getOperType() != null && operTypes != null
				&& operTypes.get(newAdjustment.getOperType()) != null
				&& operTypes.get(newAdjustment.getOperType()).getReasonLovId() != null;
	}
	
	public ru.bpc.sv2.operations.incoming.Operation getAdjustmentFilter() {
		if (adjustmentFilter == null) {
			adjustmentFilter = new ru.bpc.sv2.operations.incoming.Operation();
		}
		return adjustmentFilter;
	}

	public void setAdjustmentFilter(ru.bpc.sv2.operations.incoming.Operation adjustmentFilter) {
		this.adjustmentFilter = adjustmentFilter;
	}

	public String getGotoOperations() {
		MbOperations operBean = (MbOperations) ManagedBeanWrapper.getManagedBean("MbOperations");
		Operation filter = new Operation();
		filter.setId(_activeOperation.getId());
		operBean.setFilter(filter);
		operBean.setOperType(operType);
		operBean.setBackLink(backLink);
		operBean.search();
		
		// doesn't make sense acquiring or issuing as type is set in operType
		return "issuing|operations";
	}

	public void view() {

	}
	
	public void initializeModalPanel() {
		clearState();
		
		newAdjustment = new ru.bpc.sv2.operations.incoming.Operation();
		newAdjustment.setMsgType(OperationsConstants.MESSAGE_TYPE_PRESENTMENT);
		newAdjustment.setOperationDate(new Date());
		newAdjustment.setSourceHostDate(new Date());
		newAdjustment.setSessionId(userSessionId);
		newAdjustment.setStatus(OperationsConstants.OPERATION_STATUS_PROCESS_READY);
		newAdjustment.setSttlType(OperationsConstants.SETTLEMENT_INTERNAL_INTRAINST);

		if (FacesUtils.getSessionMapValue("OPER_TYPE") != null) {
			newAdjustment.setOperType((String) FacesUtils.getSessionMapValue("OPER_TYPE"));
			FacesUtils.setSessionMapValue("OPER_TYPE", null);
			disableOperType = true;
		}
		if (FacesUtils.getSessionMapValue("operCurrency") != null) {
			newAdjustment.setOperationCurrency((String) FacesUtils.getSessionMapValue("operCurrency"));
			FacesUtils.setSessionMapValue("operCurrency", null);
		}
		if (FacesUtils.getSessionMapValue("accountNumber") != null) {
			newAdjustment.setAccountNumber((String) FacesUtils.getSessionMapValue("accountNumber"));
			FacesUtils.setSessionMapValue("accountNumber", null);
		}
		if (FacesUtils.getSessionMapValue("acqInstId") != null) {
			newAdjustment.setAcqInstId((Integer) FacesUtils.getSessionMapValue("acqInstId"));
			FacesUtils.setSessionMapValue("acqInstId", null);
		}
		if (FacesUtils.getSessionMapValue("issInstId") != null) {
			newAdjustment.setIssInstId((Integer) FacesUtils.getSessionMapValue("issInstId"));
			FacesUtils.setSessionMapValue("issInstId", null);
		}
		if (FacesUtils.getSessionMapValue("splitHash") != null) {
			newAdjustment.setSplitHash((Integer) FacesUtils.getSessionMapValue("splitHash"));
			FacesUtils.setSessionMapValue("splitHash", null);
		}
		if (FacesUtils.getSessionMapValue("customerId") != null) {
			newAdjustment.setCustomerId((Long) FacesUtils.getSessionMapValue("customerId"));
			FacesUtils.setSessionMapValue("customerId", null);
		}
		if (FacesUtils.getSessionMapValue("entityType") != null) {
			operTypeEntityType = (String) FacesUtils.getSessionMapValue("entityType");
			FacesUtils.setSessionMapValue("entityType", null);
		}
		if (EntityNames.CARD.equals(operTypeEntityType)) {
			if (FacesUtils.getSessionMapValue("cardId") != null) {
				newAdjustment.setCardId((Long) FacesUtils.getSessionMapValue("cardId"));
				FacesUtils.setSessionMapValue("cardId", null);
			}
			if (FacesUtils.getSessionMapValue("cardInstId") != null) {
				newAdjustment.setCardInstId((Integer) FacesUtils.getSessionMapValue("cardInstId"));
				newAdjustment.setAcqInstId(newAdjustment.getCardInstId());
				newAdjustment.setIssInstId(newAdjustment.getCardInstId());
				FacesUtils.setSessionMapValue("cardInstId", null);
			}
			if (FacesUtils.getSessionMapValue("cardNumber") != null) {
				newAdjustment.setCardNumber((String) FacesUtils.getSessionMapValue("cardNumber"));
				FacesUtils.setSessionMapValue("cardNumber", null);
			}
			if (FacesUtils.getSessionMapValue("cardTypeId") != null) {
				newAdjustment.setCardTypeId((Integer) FacesUtils.getSessionMapValue("cardTypeId"));
				FacesUtils.setSessionMapValue("cardTypeId", null);
			}
			if (FacesUtils.getSessionMapValue("cardMask") != null) {
				newAdjustment.setCardMask((String) FacesUtils.getSessionMapValue("cardMask"));
				FacesUtils.setSessionMapValue("cardMask", null);
			}
			if (FacesUtils.getSessionMapValue("cardHash") != null) {
				newAdjustment.setCardHash((Long) FacesUtils.getSessionMapValue("cardHash"));
				FacesUtils.setSessionMapValue("cardHash", null);
			}
			if (FacesUtils.getSessionMapValue("cardCountry") != null) {
				newAdjustment.setCardCountry((String) FacesUtils.getSessionMapValue("cardCountry"));
				FacesUtils.setSessionMapValue("cardCountry", null);
			}
		}
		if (FacesUtils.getSessionMapValue("FUNC_PARAM") != null) {
			Object functionValue = FacesUtils.getSessionMapValue("FUNC_PARAM");
			
			System.out.println(functionValue.toString());
		}
		curMode = NEW_MODE;
	}

	private void prepareCollections(){
		collections = new ArrayList<SelectItem>(0);
		if (getParticipantFilter().getTerminalId() == null) return;
		
		SelectionParams sp = SelectionParams.build("terminalId", getParticipantFilter().getTerminalId());
		sp.setRowIndexEnd(-1);
		sp.setSortElement(new SortElement("startDate", Direction.ASC));
		collectionSource = atmDao.getAtmCollections(userSessionId, sp);
		
		if (collectionSource.length == 0) return;
		
		for (int i=0; i < collectionSource.length; i++ ){
			AtmCollection collection = collectionSource[i];
			SelectItem si = new SelectItem(i, String.format("%d - %tc", collection.getId(), collection.getStartDate()));
			collections.add(si);
		}
		
		selectedCollectionIdx = collectionSource.length - 1;
	}
	
	public List<SelectItem> getCollections(){
		if (collections == null){
			prepareCollections();
		}
		return collections;
	}
	
	public void setSelectedCollectionIdx(int index){
		if (index != selectedCollectionIdx){
			selectedCollectionIdx = index;
			AtmCollection start = collectionSource[selectedCollectionIdx];
			operDateFrom = start.getStartDate();
			if (selectedCollectionIdx + 1 < collectionSource.length){
				AtmCollection end = collectionSource[selectedCollectionIdx + 1];
				operDateTo = end.getStartDate();
			}
		}
	}
	
	public int getSelectedCollectionIdx(){
		return selectedCollectionIdx;
	}
	
	public boolean isDisableOperType() {
		return disableOperType;
	}

	public void setDisableOperType(boolean disableOperType) {
		this.disableOperType = disableOperType;
	}

	public Date getOperDateTo() {
		return operDateTo;
	}

	public void setOperDateTo(Date operDateTo) {
		this.operDateTo = operDateTo;
	}

	public Date getOperDateFrom() {
		if (operDateFrom == null){
			operDateFrom = new Date();
		}
		return operDateFrom;
	}

	public void setOperDateFrom(Date operDateFrom) {
		this.operDateFrom = operDateFrom;
	}
	
	public void updateData(){
		_operationSource.flushCache();
	}
	
	public List<SelectItem> getOperationTypes(){
		return getDictUtils().getArticles(DictNames.OPER_TYPE, true, true);
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
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
	
	public String getCtxItemEntityType() {
		return ctxItemEntityType;
	}

	public void setCtxItemEntityType() {
		MbContextMenu ctxBean = ManagedBeanWrapper.getManagedBean("MbContextMenu");
		String ctx = ctxBean.getEntityType();
		if (ctx == null || !ctx.equals(this.ctxItemEntityType)){
			ctxType = ContextTypeFactory.getInstance(ctx);
		}
		this.ctxItemEntityType = ctx;
	}
	
	public ContextType getCtxType(){
		if (ctxType == null) return null;
		Map <String, Object> map = new HashMap<String, Object>();
		
		if (_activeOperation != null) {
			if (EntityNames.OPERATION.equals(ctxItemEntityType)) {
				String participantType = getParticipantFilter().getParticipantType();
				map.put("id", _activeOperation.getId());
				map.put("objectType", objectType == null ? participantType : objectType);

				String operType = Participant.ISS_PARTICIPANT.equals(participantType) ? ModuleNames.ISSUING : ModuleNames.ACQUIRING;
				map.put("operType", operType);
			}
		}

		ctxType.setParams(map);
		return ctxType;
	}
	
	public boolean isForward(){
		return true;
	}

	public void setObjectType(String objectType) {
		this.objectType = objectType;
	}

	public Map<String, Object> getParamMap() {
		if (paramMap == null){
			paramMap = new HashMap<String, Object>();
		}
		return paramMap;
	}

	public void setParamMap(Map<String, Object> paramMap) {
		this.paramMap = paramMap;
	}

	public String getSearchTabName() {
		return searchTabName;
	}

	public void setSearchTabName(String searchTabName) {
		this.searchTabName = searchTabName;
	}

	public Long getApplicationIdFilter() {
		return applicationIdFilter;
	}

	public void setApplicationIdFilter(Long applicationIdFilter) {
		this.applicationIdFilter = applicationIdFilter;
	}
}
