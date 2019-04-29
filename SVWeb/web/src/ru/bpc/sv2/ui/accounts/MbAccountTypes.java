package ru.bpc.sv2.ui.accounts;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.accounts.AccountType;
import ru.bpc.sv2.accounts.BalanceType;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.rules.naming.NameFormat;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

@ViewScoped
@ManagedBean (name = "MbAccountTypes")
public class MbAccountTypes extends AbstractBean {
	private static final long serialVersionUID = -7391016470103609166L;

	private static String COMPONENT_ID = "1041:accountTypesTable";

	private AccountsDao _accountsDao = new AccountsDao();

	private RulesDao _rulesDao = new RulesDao();

	// private TerminalTemplate[] terminals;
	
	private MbBalanceTypes balanceTypesBean;

	private AccountType filter;
	private HashMap<Integer, String> instNames;
	private ArrayList<SelectItem> institutions;
	private ArrayList<SelectItem> entTypes;
	private ArrayList<SelectItem> productTypes;
	private Integer instId;
	private AccountType newAccountType;

	private final DaoDataModel<AccountType> _accountTypeSource;
	private final TableRowSelection<AccountType> _itemSelection;
	private AccountType _activeAccountType;
	private static final Logger logger = Logger.getLogger("ACCOUNTING");

	private int accTypesPage;
	private String entityType;
	
	private boolean createBalanceType = false;
	
	private String tabName;

	public MbAccountTypes() {
		pageLink = "account|accountTypes";
		thisBackLink = "account|accountTypes";
		
		_accountTypeSource = new DaoDataModel<AccountType>() {
			private static final long serialVersionUID = -3939602119152936456L;

			@Override
			protected AccountType[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new AccountType[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _accountsDao.getAccountTypes(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					logger.error(e.getMessage(), e);
					FacesUtils.addMessageError(e);
				}
				return new AccountType[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _accountsDao.getAccountTypesCount(userSessionId, params);
				} catch (Exception e) {
					logger.error(e.getMessage(), e);
					FacesUtils.addMessageError(e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<AccountType>(null, _accountTypeSource);
		tabName = "entitiesTab";
	}

	public DaoDataModel<AccountType> getAccountTypes() {
		return _accountTypeSource;
	}

	public AccountType getActiveAccountType() {
		return _activeAccountType;
	}

	public void setActiveAccountType(AccountType activeAccountType) {
		_activeAccountType = activeAccountType;
	}

	public SimpleSelection getItemSelection() {
		if (_activeAccountType == null && _accountTypeSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeAccountType != null && _accountTypeSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeAccountType.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeAccountType = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeAccountType = _itemSelection.getSingleSelection();
		if (_activeAccountType != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_accountTypeSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeAccountType = (AccountType) _accountTypeSource.getRowData();
		selection.addKey(_activeAccountType.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeAccountType != null) {
			setBeans();
		}
	}

	public void setBeans() {
		balanceTypesBean = (MbBalanceTypes) ManagedBeanWrapper.getManagedBean("MbBalanceTypes");

		balanceTypesBean.setActiveBalanceType(null);
		BalanceType filterBalanceType = new BalanceType();
		filterBalanceType.setInstId(_activeAccountType.getInstId());
		filterBalanceType.setAccountType(_activeAccountType.getAccountType());
		balanceTypesBean.setBalanceTypeFilter(filterBalanceType);
		balanceTypesBean.search();

		MbAccountTypeEntities entitiesBean = (MbAccountTypeEntities) ManagedBeanWrapper
				.getManagedBean("MbAccountTypeEntities");
		entitiesBean.clearFilter();
		entitiesBean.getFilter().setInstId(_activeAccountType.getInstId());
		entitiesBean.getFilter().setAccountType(_activeAccountType.getAccountType());
		entitiesBean.setInstName(_activeAccountType.getInstName());
		entitiesBean.setProductType(_activeAccountType.getProductType());
		entitiesBean.search();

		MbIsoAccountTypes isoTypesBean = (MbIsoAccountTypes) ManagedBeanWrapper
				.getManagedBean("MbIsoAccountTypes");
		isoTypesBean.fullCleanBean();
		isoTypesBean.getFilter().setInstId(_activeAccountType.getInstId());
		isoTypesBean.getFilter().setAccountType(_activeAccountType.getAccountType());
		isoTypesBean.setInstName(_activeAccountType.getInstName());
		isoTypesBean.search();
	}

	public void clearFilter() {
		clearBean();
		filter = null;
		entityType = null;
		
		searching = false;
	}

	public void search() {
		clearBean();

		searching = true;
	}

	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}
		
		if (entityType != null) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setValue(entityType);
			filters.add(paramFilter);
		}

		if (filter.getProductType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("productType");
			paramFilter.setValue(filter.getProductType());
			filters.add(paramFilter);
		}
	}

	public void resetBeans() {
		balanceTypesBean = (MbBalanceTypes) ManagedBeanWrapper.getManagedBean("MbBalanceTypes");
		balanceTypesBean.setSearching(false);
		balanceTypesBean.setBalanceTypeFilter(null);
		balanceTypesBean.clearBean();

		MbAccountTypeEntities entitiesBean = (MbAccountTypeEntities) ManagedBeanWrapper
				.getManagedBean("MbAccountTypeEntities");
		entitiesBean.clearFilter();

		MbIsoAccountTypes isoTypesBean = (MbIsoAccountTypes) ManagedBeanWrapper
				.getManagedBean("MbIsoAccountTypes");
		isoTypesBean.fullCleanBean();
		isoTypesBean.setSearching(false);
	}

	public AccountType getFilter() {
		if (filter == null) {
			filter = new AccountType();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(AccountType filter) {
		this.filter = filter;
	}

	public void add() {
		newAccountType = new AccountType();
		newAccountType.setInstId(filter.getInstId());

		balanceTypesBean = (MbBalanceTypes) ManagedBeanWrapper.getManagedBean("MbBalanceTypes");
		BalanceType balType = new BalanceType();
		balType.setInstId(filter.getInstId());
		balanceTypesBean.setNewBalanceType(balType);
		balanceTypesBean.setCurMode(MbBalanceTypes.NEW_MODE);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newAccountType = _activeAccountType.clone();
		} catch (CloneNotSupportedException e) {
			newAccountType = _activeAccountType;
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isEditMode()) {
				newAccountType = _accountsDao.editAccountType(userSessionId, newAccountType, curLang);
				_accountTypeSource.replaceObject(_activeAccountType, newAccountType);
			} else {
				newAccountType = _accountsDao.addAccountTypeWithBalanceType(userSessionId,
						newAccountType, balanceTypesBean.getNewBalanceType(), curLang);
				_itemSelection.addNewObjectToList(newAccountType);

				balanceTypesBean.search();
			}
			curMode = VIEW_MODE;
			_activeAccountType = newAccountType;
			setBeans();
			FacesUtils.addMessageInfo("Account has been saved.");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_accountsDao.removeAccountType(userSessionId, _activeAccountType);
			curMode = VIEW_MODE;

			_activeAccountType = _itemSelection.removeObjectFromList(_activeAccountType);
			if (_activeAccountType == null) {
				clearBean();
			} else {
				setBeans();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public int getAccTypesPage() {
		return accTypesPage;
	}

	public void setAccTypesPage(int accTypesPage) {
		this.accTypesPage = accTypesPage;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public HashMap<Integer, String> getInstNames() {
		if (instNames == null)
			instNames = new HashMap<Integer, String>();
		return instNames;
	}

	public ArrayList<SelectItem> getNameFormats() {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		try {
			SelectionParams params = new SelectionParams();
			String instId = null;
			if (getNewAccountType().getInstId() == null) {
				instId = "9999";
			} else {
				instId = getNewAccountType().getInstId().toString();
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
			paramFilter.setValue(EntityNames.ACCOUNT);
			filtersNameFormat.add(paramFilter);

			paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(SessionWrapper.getField("language"));
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

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public List<SelectItem> getEntTypes() {
		if(entTypes == null) {
			entTypes = (ArrayList<SelectItem>)getDictUtils().getLov(LovConstants.ACCOUNT_ENTITY_TYPES);
		}
		if (entTypes == null)
			entTypes = new ArrayList<SelectItem>();
		return entTypes;
	}

	public AccountType getNewAccountType() {
		if (newAccountType == null) {
			newAccountType = new AccountType();
		}
		return newAccountType;
	}

	public void setNewAccountType(AccountType newAccountType) {
		this.newAccountType = newAccountType;
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public String getAccountTypeType() {
		return DictNames.ACCOUNT_TYPE;
	}

	public List<SelectItem> getAllAccountTypes() {
		return getDictUtils().getLov(LovConstants.ACCOUNT_TYPES_ALL);
	}

	public List<SelectItem> getProductTypes() {
		if(productTypes == null){
			productTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.PRODUCT_TYPES);
		}
		if (productTypes == null)
			productTypes = new ArrayList<SelectItem>();
		return productTypes;
	}

	public void clearBean() {
		// reset selection
		_itemSelection.clearSelection();
		_activeAccountType = null;

		// reset dependent bean
		resetBeans();

		_accountTypeSource.flushCache();
	}

	public void changeInstitution(ValueChangeEvent event) {
		Integer newInst = (Integer) event.getNewValue();
		balanceTypesBean.getNewBalanceType().setInstId(newInst);
	}

	public void createAccountType() {
		createBalanceType = false;
	}

	public void createBalanceType() {
		createBalanceType = true;
	}

	public boolean getCreateBalanceType() {
		return createBalanceType;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		
		if (tabName.equalsIgnoreCase("balanceTypesTab")) {
			MbBalanceTypes bean = (MbBalanceTypes) ManagedBeanWrapper
					.getManagedBean("MbBalanceTypes");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("isoTypesTab")) {
			MbIsoAccountTypes bean = (MbIsoAccountTypes) ManagedBeanWrapper
					.getManagedBean("MbIsoAccountTypes");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
		
	}

	public String getSectionId() {
		return SectionIdConstants.OPERATION_ACC_ACCTYPE;
	}
}
