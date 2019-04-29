package ru.bpc.sv2.ui.acquiring;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.acquiring.Terminal;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AcquiringDao;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.context.ContextType;
import ru.bpc.sv2.ui.context.ContextTypeFactory;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import javax.servlet.http.HttpServletRequest;
import java.text.ParseException;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbTerminalsBottom")
public class MbTerminalsBottom extends AbstractBean {
	/**
	 * 
	 */
	private static final long serialVersionUID = -3210320494333514304L;

	private static final Logger logger = Logger.getLogger("ACQUIRING");

	private AcquiringDao _acquiringDao = new AcquiringDao();

	// private TerminalTemplate[] terminals;
	private LinkedHashMap<Integer, Terminal> terminals;
	private ArrayList<SelectItem> institutions;
	private Terminal _activeTerminal;
	

	private boolean _managingNew;
	private Terminal filterTerm;
	
	private final DaoDataModel<Terminal> _terminalSource;
	private final TableRowSelection<Terminal> _itemSelection;

	private String backLink;

	private Long accountId;
	
	private ContextType ctxType;
	private String ctxItemEntityType;
	
	private static String COMPONENT_ID = "operationsTable";
	private String tabName;
	private String searchTabName;
	private HashMap<String, Object> paramMap;
	private String parentSectionId;

	public MbTerminalsBottom() {
		
		

		_terminalSource = new DaoDataModel<Terminal>() {
			/**
			 * 
			 */
			private static final long serialVersionUID = 6664385754798298580L;

			@Override
			protected Terminal[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Terminal[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _acquiringDao.getTerminalsCur(userSessionId, params, getParamMap());
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Terminal[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _acquiringDao.getTerminalsCountCur(userSessionId, getParamMap());
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Terminal>(null, _terminalSource);
		
		HttpServletRequest req = RequestContextHolder.getRequest();
		String sectionId = req.getParameter("sectionId");
		String filterId = req.getParameter("filterId");
				
		if (sectionId != null && filterId != null) {
			selectedSectionFilter = Integer.parseInt(filterId);
			applySectionFilter(selectedSectionFilter);			
		}
	}

	public DaoDataModel<Terminal> getTerminals() {
		return _terminalSource;
	}

	public Terminal getActiveTerminal() {
		return _activeTerminal;
	}

	public void setActiveTerminal(Terminal activeTerminal) {
		_activeTerminal = activeTerminal;
	}

	public SimpleSelection getItemSelection() {
		if (_activeTerminal == null && _terminalSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeTerminal != null && _terminalSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeTerminal.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeTerminal = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeTerminal = _itemSelection.getSingleSelection();

		if (_activeTerminal != null) {
			
		}
	}

	public void setFirstRowActive() {
		_terminalSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeTerminal = (Terminal) _terminalSource.getRowData();
		selection.addKey(_activeTerminal.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeTerminal != null) {
			
		}
	}

	
	public void clearFilter() {
		filterTerm = null;
		getParamMap().clear();
		clearState();
		searching = false;
		clearSectionFilter();
	}

	public void searchTerminal() {
		clearState();
		searching = true;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeTerminal = null;
		_terminalSource.flushCache();
	}

	private void setFilters() {
		getFilterTerm();

		filters = new ArrayList<Filter>();

		// as both terminals and terminal templates are stored
		// in the same table we use IS_TEMPLATE = 0 to get terminals
		Filter paramFilter = new Filter();
		paramFilter.setElement("isTemplate");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue("0");
		filters.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("LANG");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (getFilterTerm().getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("ID");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilterTerm().getId());
			filters.add(paramFilter);
		}

		if (getFilterTerm().getTerminalNumber() != null && !getFilterTerm().getTerminalNumber().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("TERMINAL_NUMBER");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(getFilterTerm().getTerminalNumber().toUpperCase().replaceAll("[*]", "%").replaceAll(
					"[?]", "_"));
			filters.add(paramFilter);
		}

		if (getFilterTerm().getInstId() != null) {
			paramFilter = new Filter("INST_ID", getFilterTerm().getInstId());
			filters.add(paramFilter);
		}

		if (getFilterTerm().getMerchantId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("MERCHANT_ID");
			paramFilter.setValue(getFilterTerm().getMerchantId());
			filters.add(paramFilter);
		}

		if (getFilterTerm().getMerchantNumber() != null && !getFilterTerm().getMerchantNumber().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("MERCHANT_NUMBER");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(getFilterTerm().getMerchantNumber().toUpperCase().replaceAll("[*]", "%").replaceAll(
					"[?]", "_"));
			filters.add(paramFilter);
		}

		if (getFilterTerm().getStatus() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("STATUS");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilterTerm().getStatus());
			filters.add(paramFilter);
		}

		if (accountId != null) {
			paramFilter = new Filter();
			paramFilter.setElement("ACCOUNT_ID");
			paramFilter.setValue(accountId);
			filters.add(paramFilter);

		}
		if (getFilterTerm().getContractId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("CONTRACT_ID");
			paramFilter.setValue(getFilterTerm().getContractId());
			filters.add(paramFilter);
		}
		if (getFilterTerm().getCustomerNumber() != null &&
				getFilterTerm().getCustomerNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("customerNumber");
			paramFilter.setValue(getFilterTerm().getCustomerNumber().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		
		if (getFilterTerm().getCustomerId() != null ) {
			paramFilter = new Filter();
			paramFilter.setElement("CUSTOMER_ID");
			paramFilter.setValue(getFilterTerm().getCustomerId());
			filters.add(paramFilter);
		}
		
		if (getFilterTerm().getTerminalType() != null) {
			paramFilter = new Filter("TERMINAL_TYPE", getFilterTerm().getTerminalType());
			filters.add(paramFilter);
		}
		
		if (getFilterTerm().getAuthId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("authId");
			paramFilter.setValue(getFilterTerm().getAuthId());
			filters.add(paramFilter);
		}
		
		getParamMap().put("param_tab", filters.toArray(new Filter[filters.size()]));
        getParamMap().put("tab_name", searchTabName);
	}

	public Long getAccountId() {
		return accountId;
	}

	public void setAccountId(Long accountId) {
		this.accountId = accountId;
	}

	public Terminal getFilterTerm() {
		if (filterTerm == null) {
			filterTerm = new Terminal();
		}
		return filterTerm;
	}

	public void setFilterTerm(Terminal filterTerm) {
		this.filterTerm = filterTerm;
	}

	public void changeTerminal(ValueChangeEvent event) {
		Integer id = (Integer) event.getNewValue();
		_activeTerminal = terminals.get(id);
	}

	public List<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public boolean isManagingNew() {
		return _managingNew;
	}

	public void setManagingNew(boolean managingNew) {
		_managingNew = managingNew;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public String doBack() {
		FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);
		return backLink;
	}

	public ArrayList<SelectItem> getTerminalItems() {
		if (terminals == null) {
			return new ArrayList<SelectItem>(0);
		}
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		// SelectItem[] items = new SelectItem[terminals.size()];
		for (Terminal terminal : terminals.values()) {
			items.add(new SelectItem(terminal.getId(), String.valueOf(terminal.getId())));
		}
		return items;
	}

	public void setTerminals(LinkedHashMap<Integer, Terminal> terminals) {
		this.terminals = terminals;
	}

	public void cancel() {
		_managingNew = false;
		resetBean();
	}

	public void resetBean() {
		_activeTerminal = new Terminal();
		if (terminals != null)
			terminals.clear();
	}

	// ===--- Getters for values from dictionary ---===//
	public ArrayList<SelectItem> getTerminalTypes() {
		return getDictUtils().getArticles(DictNames.TERMINAL_TYPE, true, false);
	}

	public ArrayList<SelectItem> getCardDataInputCaps() {
		return getDictUtils().getArticles(DictNames.CARD_DATA_INPUT_CAP, true, false);
	}

	public ArrayList<SelectItem> getCrdhAuthCaps() {
		return getDictUtils().getArticles(DictNames.CRDH_AUTH_CAP, true, false);
	}

	public ArrayList<SelectItem> getCardCaptureCaps() {
		return getDictUtils().getArticles(DictNames.CARD_CAPTURE_CAP, true, false);
	}

	public ArrayList<SelectItem> getTermOperatingEnvs() {
		return getDictUtils().getArticles(DictNames.TERM_OPERATING_ENV, true, false);
	}

	public ArrayList<SelectItem> getCrdhDataPresents() {
		return getDictUtils().getArticles(DictNames.CRDH_DATA_PRESENT, true, false);
	}

	public ArrayList<SelectItem> getCardDataPresents() {
		return getDictUtils().getArticles(DictNames.CARD_DATA_PRESENT, true, false);
	}

	public ArrayList<SelectItem> getCardDataInputModes() {
		return getDictUtils().getArticles(DictNames.CARD_DATA_INPUT_MODE, true, false);
	}

	public ArrayList<SelectItem> getCrdhAuthMethods() {
		return getDictUtils().getArticles(DictNames.CRDH_AUTH_METHOD, true, false);
	}

	public ArrayList<SelectItem> getCrdhAuthEntities() {
		return getDictUtils().getArticles(DictNames.CRDH_AUTH_ENTITY, true, false);
	}

	public ArrayList<SelectItem> getCardDataOutputCaps() {
		return getDictUtils().getArticles(DictNames.CARD_DATA_OUTPUT_CAP, true, false);
	}

	public ArrayList<SelectItem> getTermDataOutputCaps() {
		return getDictUtils().getArticles(DictNames.TERM_DATA_OUTPUT_CAP, true, false);
	}

	public ArrayList<SelectItem> getPinCaptureCaps() {
		return getDictUtils().getArticles(DictNames.PIN_CAPTURE_CAP, true, false);
	}

	public ArrayList<SelectItem> getStatuses() {
		return getDictUtils().getArticles(DictNames.TERMINAL_STATUS, true, false);
	}

	// ===--- Getters for values from dictionary (END) ---===//


	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filterTerm = new Terminal();
				setFilterForm(filterRec);
				if (searchAutomatically) searchTerminal();
			}
		
			sectionFilterModeEdit = true;
					
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} 
	}
	
	private void setFilterForm(Map<String, String> filterRec) throws ParseException {
		if (filterRec.get("id") != null) {
			filterTerm.setId(Integer.valueOf(filterRec.get("id")));
		}
		if (filterRec.get("terminalNumber") != null) {
			filterTerm.setTerminalNumber(filterRec.get("terminalNumber"));
		}
		if (filterRec.get("merchantId") != null) {
			filterTerm.setMerchantId(Integer.valueOf(filterRec.get("merchantId")));
		}
		if (filterRec.get("merchantNumber") != null) {
			filterTerm.setMerchantNumber(filterRec.get("merchantNumber"));
		}
		if (filterRec.get("status") != null) {
			filterTerm.setStatus(filterRec.get("status"));
		}
	}
	
	@Override
	public void saveSectionFilter() {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper.getManagedBean("filterFactory");
			
			Map<String, String> filterRec = new HashMap<String, String>();
			filterTerm = getFilterTerm();
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
	
	private void setFilterRec(Map<String, String> filterRec) {
		
		if (filterTerm.getId() != null) {
			filterRec.put("id", filterTerm.getId().toString());
		}
		if (filterTerm.getTerminalNumber() != null && filterTerm.getTerminalNumber().trim().length() > 0) {
			filterRec.put("terminalNumber", filterTerm.getTerminalNumber());
		}
		if (filterTerm.getMerchantId() != null) {
			filterRec.put("merchantId", filterTerm.getMerchantId().toString());
		}
		if (filterTerm.getMerchantNumber() != null 
				&& filterTerm.getMerchantNumber().trim().length() > 0) {
			filterRec.put("merchantNumber", filterTerm.getMerchantNumber());
		}
		if (filterTerm.getStatus() != null && filterTerm.getStatus().trim().length() > 0) {
			filterRec.put("status", filterTerm.getStatus());
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.ACQUIRING_TERMINAL;
	}
	
	public String gotoTerminals() {
		MbTerminal termBean = (MbTerminal)ManagedBeanWrapper.getManagedBean("MbTerminal");
		Terminal filter = new Terminal();		
		filter.setTerminalNumber(_activeTerminal.getTerminalNumber());
		filter.setInstId(_activeTerminal.getInstId());
		termBean.setFilter(filter);
		termBean.setSearching(true);
		return "acquiring|terminals";
	}

	public Terminal loadTerminal() {
		_activeTerminal = null;

		setFilters();
		SelectionParams params = new SelectionParams();
		params.setFilters((Filter[]) filters.toArray(new Filter[filters.size()]));
		
		try {
			Terminal[] terminals = _acquiringDao.getTerminals(userSessionId, params);
			if (terminals.length > 0) {
				_activeTerminal = terminals[0];
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _activeTerminal;
	}
	
	public String getCtxItemEntityType() {
		return ctxItemEntityType;
	}

	public void setCtxItemEntityType() {
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		String ctx = ctxBean.getEntityType();
		if (ctx == null || !ctx.equals(this.ctxItemEntityType)){
			ctxType = ContextTypeFactory.getInstance(ctx);
		}
		this.ctxItemEntityType = ctx;
	}
	
	public ContextType getCtxType(){
		if (ctxType == null) setCtxItemEntityType();
		Map <String, Object> map = new HashMap<String, Object>();

		if (_activeTerminal != null) {
			if (EntityNames.TERMINAL.equals(ctxItemEntityType)) {
				map.put("id", _activeTerminal.getId());
				map.put("instId", _activeTerminal.getInstId());
				map.put("terminalNumber", _activeTerminal.getTerminalNumber());
				ctxType.setParams(map);
			}
		}
		ctxType.setParams(map);
		return ctxType;
	}
	
private Map<Long, String> mccSelectionTemplatesMap;
	
	public Map<Long, String> getMccSelectionTemplatesMap(){
		if (mccSelectionTemplatesMap == null){
			List<SelectItem> selectionTemplates = getDictUtils().getLov(LovConstants.MCC_SELECTION_TEMPLATE);
			mccSelectionTemplatesMap = new HashMap<Long, String>();
			for (SelectItem item : selectionTemplates){
				mccSelectionTemplatesMap.put(new Long(item.getValue().toString()), item.getLabel());
			}
		}
		return mccSelectionTemplatesMap;
	}
	
	public boolean isForward(){
		return true;
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

	public HashMap<String, Object> getParamMap() {
		if (paramMap == null){
			paramMap = new HashMap<String, Object>();
		}
		return paramMap;
	}

	public void setParamMap(HashMap<String, Object> paramMap) {
		this.paramMap = paramMap;
	}

	public String getSearchTabName() {
		return searchTabName;
	}

	public void setSearchTabName(String searchTabName) {
		this.searchTabName = searchTabName;
	}
	
}
