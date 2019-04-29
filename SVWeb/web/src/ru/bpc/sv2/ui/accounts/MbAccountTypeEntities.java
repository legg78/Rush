package ru.bpc.sv2.ui.accounts;

import java.util.ArrayList;

import java.util.HashMap;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.accounts.AccountTypeEntity;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbAccountTypeEntities")
public class MbAccountTypeEntities extends AbstractBean{
	private AccountsDao _accountsDao = new AccountsDao();

	

	private AccountTypeEntity accountTypeFilter;
	private ArrayList<SelectItem> institutions;
	private AccountTypeEntity newAccountTypeEntity;
	private String instName;


	private final DaoDataModel<AccountTypeEntity> _accountTypeEntitySource;
	private final TableRowSelection<AccountTypeEntity> _itemSelection;
	private AccountTypeEntity _activeAccountTypeEntity;
	private static final Logger logger = Logger.getLogger("ACCOUNTING");

	private int accTypesPage;
	private String productType;
	
	private static String COMPONENT_ID = "accountTypeEntitiesTable";
	private String tabName;
	private String parentSectionId;
	
	public MbAccountTypeEntities() {
		

		_accountTypeEntitySource = new DaoDataModel<AccountTypeEntity>() {
			@Override
			protected AccountTypeEntity[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new AccountTypeEntity[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _accountsDao.getAccountTypeEntities(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error(e.getMessage(), e);
					return new AccountTypeEntity[0];
				}
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _accountsDao.getAccountTypeEntitiesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error(e.getMessage(), e);
					return 0;
				}
			}
		};

		_itemSelection = new TableRowSelection<AccountTypeEntity>(null, _accountTypeEntitySource);
	}

	public DaoDataModel<AccountTypeEntity> getAccountTypeEntities() {
		return _accountTypeEntitySource;
	}

	public AccountTypeEntity getActiveAccountTypeEntity() {
		return _activeAccountTypeEntity;
	}

	public void setActiveAccountTypeEntity(AccountTypeEntity activeAccountTypeEntity) {
		_activeAccountTypeEntity = activeAccountTypeEntity;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeAccountTypeEntity == null && _accountTypeEntitySource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeAccountTypeEntity != null && _accountTypeEntitySource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeAccountTypeEntity.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeAccountTypeEntity = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeAccountTypeEntity = _itemSelection.getSingleSelection();
		if (_activeAccountTypeEntity != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_accountTypeEntitySource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeAccountTypeEntity = (AccountTypeEntity) _accountTypeEntitySource.getRowData();
		selection.addKey(_activeAccountTypeEntity.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeAccountTypeEntity != null) {
			setBeans();
		}
	}

	public void setBeans() {
	}

	public void clearFilter() {
		clearBean();
		accountTypeFilter = new AccountTypeEntity();

		searching = false;
	}

	public void search() {
		clearBean();

		searching = true;
	}

	public void setFilters() {
		accountTypeFilter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");	// to get institution name
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (accountTypeFilter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(accountTypeFilter.getInstId().toString());
			filters.add(paramFilter);
		}
		if (accountTypeFilter.getAccountType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("accountType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(accountTypeFilter.getAccountType());
			filters.add(paramFilter);
		}
	}

	public AccountTypeEntity getFilter() {
		if (accountTypeFilter == null) {
			accountTypeFilter = new AccountTypeEntity();
		}
		return accountTypeFilter;
	}

	public void setFilter(AccountTypeEntity accountTypeFilter) {
		this.accountTypeFilter = accountTypeFilter;
	}

	public void add() {
		newAccountTypeEntity = new AccountTypeEntity();
		newAccountTypeEntity.setInstId(accountTypeFilter.getInstId());
		newAccountTypeEntity.setAccountType(accountTypeFilter.getAccountType());
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newAccountTypeEntity = _activeAccountTypeEntity.clone();
		} catch (CloneNotSupportedException e) {
			newAccountTypeEntity = _activeAccountTypeEntity;
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isNewMode()) {
				newAccountTypeEntity = _accountsDao.addAccountTypeEntity(userSessionId,
						newAccountTypeEntity);
				_itemSelection.addNewObjectToList(newAccountTypeEntity);
			}

			curMode = VIEW_MODE;
			_activeAccountTypeEntity = newAccountTypeEntity;
			setBeans();
			FacesUtils.addMessageInfo("Account type entity has been saved.");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_accountsDao.removeAccountTypeEntity(userSessionId, _activeAccountTypeEntity);
			curMode = VIEW_MODE;

			String msg = "Account type entity with id = " + _activeAccountTypeEntity.getId()
					+ " has been deleted.";

			_activeAccountTypeEntity = _itemSelection
					.removeObjectFromList(_activeAccountTypeEntity);
			if (_activeAccountTypeEntity == null) {
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

	public int getAccTypesPage() {
		return accTypesPage;
	}

	public void setAccTypesPage(int accTypesPage) {
		this.accTypesPage = accTypesPage;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public List<SelectItem> getEntTypes() {
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("PRODUCT_TYPE", productType);
		
		List<SelectItem> types = getDictUtils().getLov(LovConstants.ACCOUNT_ENTITY_TYPES_DEPENDENT, map);
		return types;
	}

	public AccountTypeEntity getNewAccountTypeEntity() {
		if (newAccountTypeEntity == null) {
			newAccountTypeEntity = new AccountTypeEntity();
		}
		return newAccountTypeEntity;
	}

	public void setNewAccountTypeEntity(AccountTypeEntity newAccountTypeEntity) {
		this.newAccountTypeEntity = newAccountTypeEntity;
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public String getAccountTypeEntityType() {
		return DictNames.ACCOUNT_TYPE;
	}

	public ArrayList<SelectItem> getAllAccountTypeEntitys() {
		return getDictUtils().getArticles(DictNames.ACCOUNT_TYPE, true, false);
	}

	public void clearBean() {
		// reset selection
		_itemSelection.clearSelection();
		_activeAccountTypeEntity = null;

		_accountTypeEntitySource.flushCache();
	}

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
	}

	public String getProductType() {
		return productType;
	}

	public void setProductType(String productType) {
		this.productType = productType;
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

	@Override
	public String getTableState() {
		MbAccountTypes bean = (MbAccountTypes) ManagedBeanWrapper
				.getManagedBean("MbAccountTypes");
		if (bean != null) {
			setTabName(bean.getTabName());
			setParentSectionId(bean.getSectionId());
		}
		return super.getTableState();
	}
}
