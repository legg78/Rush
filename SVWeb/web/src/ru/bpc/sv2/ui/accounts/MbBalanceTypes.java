package ru.bpc.sv2.ui.accounts;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.accounts.BalanceType;
import ru.bpc.sv2.common.rates.RateType;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.rules.naming.NameFormat;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbBalanceTypes")
public class MbBalanceTypes extends AbstractBean {
	private AccountsDao _accountsDao = new AccountsDao();

	private CommonDao _commonDao = new CommonDao();

	private RulesDao _rulesDao = new RulesDao();

	
	private BalanceType balanceTypeFilter;
	private BalanceType newBalanceType;

	private HashMap<Integer, String> instNames;
	private ArrayList<SelectItem> institutions;
	private ArrayList<SelectItem> allBalanceTypes;
	private ArrayList<SelectItem>  balanceAlgorithms;

	private final DaoDataModel<BalanceType> _balanceTypeSource;
	private final TableRowSelection<BalanceType> _itemSelection;
	private BalanceType _activeBalanceType;
	private static final Logger logger = Logger.getLogger("ACCOUNTING");
	private int balTypesPage;

	private HashMap<Integer, String> avalImpacts;
	
	private static String COMPONENT_ID = "balanceTypesTable";
	private String tabName;
	private String parentSectionId;

	public MbBalanceTypes() {
		

		_balanceTypeSource = new DaoDataModel<BalanceType>() {
			@Override
			protected BalanceType[] loadDaoData(SelectionParams params) {
				if (!searching)
					return new BalanceType[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));

					return _accountsDao.getBalanceTypes(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new BalanceType[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));

					return _accountsDao.getBalanceTypesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<BalanceType>(null, _balanceTypeSource);
	}

	/* Balance types control functions */
	public DaoDataModel<BalanceType> getBalanceTypes() {
		return _balanceTypeSource;
	}

	public BalanceType getActiveBalanceType() {
		return _activeBalanceType;
	}

	public void setActiveBalanceType(BalanceType activeBalanceType) {
		_activeBalanceType = activeBalanceType;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeBalanceType == null && _balanceTypeSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeBalanceType != null && _balanceTypeSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeBalanceType.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeBalanceType = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeBalanceType = _itemSelection.getSingleSelection();
	}

	public void setFirstRowActive() {
		_balanceTypeSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeBalanceType = (BalanceType) _balanceTypeSource.getRowData();
		selection.addKey(_activeBalanceType.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeBalanceType != null) {
			setBeans();
		}
	}

	/* END - Balance types control functions */

	public void add() {
		newBalanceType = new BalanceType();
		newBalanceType.setAccountType(getBalanceTypeFilter().getAccountType());
		newBalanceType.setInstId(getBalanceTypeFilter().getInstId());
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newBalanceType = _activeBalanceType.clone();
		} catch (CloneNotSupportedException e) {
			newBalanceType = _activeBalanceType;
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isEditMode()) {
				newBalanceType = _accountsDao.editBalanceType(userSessionId, newBalanceType);
				_balanceTypeSource.replaceObject(_activeBalanceType, newBalanceType);
			} else {
				newBalanceType = _accountsDao.addBalanceType(userSessionId, newBalanceType);
				_itemSelection.addNewObjectToList(newBalanceType);
			}
			curMode = VIEW_MODE;
			_activeBalanceType = newBalanceType;

			FacesUtils.addMessageInfo("Balance has been saved.");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_accountsDao.removeBalanceType(userSessionId, _activeBalanceType);
			curMode = VIEW_MODE;
			String msg = "Balance type with id = " + _activeBalanceType.getId()
					+ " has been deleted.";

			_activeBalanceType = _itemSelection.removeObjectFromList(_activeBalanceType);
			if (_activeBalanceType == null) {
				clearBean();
			} else {
				setBeans();
			}

			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void search() {
		curMode = VIEW_MODE;

		setSearching(true);
		_balanceTypeSource.flushCache();
		_itemSelection.clearSelection();
		_activeBalanceType = null;
	}

	private void setBeans() {

	}

	public int getBalTypesPage() {
		return balTypesPage;
	}

	public void setBalTypesPage(int balTypesPage) {
		this.balTypesPage = balTypesPage;
	}

	public BalanceType getBalanceTypeFilter() {
		if (balanceTypeFilter == null)
			balanceTypeFilter = new BalanceType();
		return balanceTypeFilter;
	}

	public void setBalanceTypeFilter(BalanceType balanceTypeFilter) {
		this.balanceTypeFilter = balanceTypeFilter;
	}

	public void setFilters() {
		balanceTypeFilter = getBalanceTypeFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (balanceTypeFilter.getAccountType() != null
				&& !balanceTypeFilter.getAccountType().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("accountType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(balanceTypeFilter.getAccountType());
			filters.add(paramFilter);
		}
		if (balanceTypeFilter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(balanceTypeFilter.getInstId().toString());
			filters.add(paramFilter);
		}
	}

	public String getBalanceTypeType() {
		return DictNames.BALANCE_TYPE;
	}

	public ArrayList<SelectItem> getAllBalanceTypes() {
		if(allBalanceTypes == null){
			allBalanceTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.BALANCE_TYPES);
		}
		if (allBalanceTypes == null)
			allBalanceTypes = new ArrayList<SelectItem>();
		return allBalanceTypes;
	}

	public BalanceType getNewBalanceType() {
		if (newBalanceType == null) {
			newBalanceType = new BalanceType();
		}
		return newBalanceType;
	}

	public void setNewBalanceType(BalanceType newBalanceType) {
		this.newBalanceType = newBalanceType;
	}

	public ArrayList<SelectItem> getStatuses() {
		return getDictUtils().getArticles(DictNames.BALANCE_STATUS, true, false);
	}

	public String getAccountTypeType() {
		return DictNames.ACCOUNT_TYPE;
	}

	public ArrayList<SelectItem> getAllAccountTypes() {
		return getDictUtils().getArticles(DictNames.ACCOUNT_TYPE, true, false);
	}

	public ArrayList<SelectItem> getRateTypes() {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		try {
			SelectionParams params = new SelectionParams();

			String instId = null;
			if (getNewBalanceType().getInstId() == null) {
				instId = "9999";
			} else {
				instId = getNewBalanceType().getInstId().toString();
			}

			List<Filter> filtersNameFormat = new ArrayList<Filter>();

			Filter paramFilter = null;

			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(instId);
			filtersNameFormat.add(paramFilter);

			params.setFilters(filtersNameFormat.toArray(new Filter[filtersNameFormat.size()]));
			params.setRowIndexEnd(-1);
			RateType[] rateTypes = _commonDao.getRateTypes(userSessionId, params);
			for (RateType type : rateTypes) {
				items.add(new SelectItem(type.getRateType(), getDictUtils().getAllArticlesDesc().get(
						type.getRateType())));
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

	public ArrayList<SelectItem> getImpacts() {
		ArrayList<SelectItem> impacts = new ArrayList<SelectItem>();
		for (Integer key : getAvalImpacts().keySet()) {
			impacts.add(new SelectItem(key, getAvalImpacts().get(key)));
		}
		return impacts;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public HashMap<Integer, String> getAvalImpacts() {
		if (avalImpacts == null) {
			avalImpacts = new HashMap<Integer, String>();
			avalImpacts.put(new Integer(-1), "Negative");
			avalImpacts.put(new Integer(0), "Neutral");
			avalImpacts.put(new Integer(1), "Positive");
		}
		return avalImpacts;
	}

	public HashMap<Integer, String> getInstNames() {
		if (instNames == null)
			instNames = new HashMap<Integer, String>();
		return instNames;
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public int getCurMode() {
		return curMode;
	}

	public void clearBean() {
		// reset selection
		_itemSelection.clearSelection();
		_activeBalanceType = null;
		_balanceTypeSource.flushCache();
	}

	public ArrayList<SelectItem> getFormats() {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		try {
			SelectionParams params = new SelectionParams();
			String instId = null;
			if (getNewBalanceType().getInstId() == null) {
				instId = "9999";
			} else {
				instId = getNewBalanceType().getInstId().toString();
			}

			List<Filter> filtersNameFormat = new ArrayList<Filter>();

			Filter paramFilter = null;

			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(instId);
			filtersNameFormat.add(paramFilter);

			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(EntityNames.BALANCE);
			filtersNameFormat.add(paramFilter);

			paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(userLang);
			filtersNameFormat.add(paramFilter);

			params.setFilters(filtersNameFormat.toArray(new Filter[filtersNameFormat.size()]));
			params.setRowIndexEnd(-1);
			NameFormat[] formats = _rulesDao.getNameFormats(userSessionId, params);
			for (NameFormat format : formats) {
				items.add(new SelectItem(format.getId(), format.getLabel()));
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

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}
	
	private List<SelectItem> updateMacrosTypesCache;
	private Map<Integer, String> updateMacrosTypesMap;
	
	public List<SelectItem> getUpdateMacrosTypes(){
		if (updateMacrosTypesCache == null){
			updateMacrosTypesCache = getDictUtils().getLov(LovConstants.UPDATE_MACROS_TYPES);
			updateMacrosTypesMap = new HashMap<Integer, String>();
			for (SelectItem item : updateMacrosTypesCache){
				String value = (String) item.getValue();
				String label = item.getLabel();
				updateMacrosTypesMap.put(Integer.valueOf(value), label);
			}
		}
		return updateMacrosTypesCache;
	}
	
	public Map<Integer, String> getUpdateMacrosTypesMap(){
		return updateMacrosTypesMap;
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
	
	public ArrayList<SelectItem> getBalanceAlgorithms(){
		if(balanceAlgorithms == null){
			balanceAlgorithms = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.BALANCE_ALGORITHM);
		}
		if (balanceAlgorithms == null)
			balanceAlgorithms = new ArrayList<SelectItem>();
		return balanceAlgorithms;
	}
}
