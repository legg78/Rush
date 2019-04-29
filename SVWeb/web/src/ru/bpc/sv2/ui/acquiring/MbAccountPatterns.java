package ru.bpc.sv2.ui.acquiring;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.acquiring.AccountPattern;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.AcquiringDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbAccountPatterns")
public class MbAccountPatterns extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ACQUIRING");

	private AcquiringDao _acquiringDao = new AcquiringDao();

	

	private AccountPattern filter;

	private final DaoDataModel<AccountPattern> _accountPatternsSource;
	private final TableRowSelection<AccountPattern> _itemSelection;
	private AccountPattern _activeAccountPattern;
	private AccountPattern newAccountPattern;

	private static String COMPONENT_ID = "accountPatternsTable";
	private String tabName;
	private String parentSectionId;
	
	public MbAccountPatterns() {
		

		_accountPatternsSource = new DaoDataModel<AccountPattern>() {
			@Override
			protected AccountPattern[] loadDaoData(SelectionParams params) {
				if (getFilter().getSchemeId() == null) {
					return new AccountPattern[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _acquiringDao.getAccountPatterns(userSessionId, params);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
					setDataSize(0);
					return new AccountPattern[0];
				}
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (getFilter().getSchemeId() == null) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _acquiringDao.getAccountPatternsCount(userSessionId, params);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return 0;
				}
			}
		};

		_itemSelection = new TableRowSelection<AccountPattern>(null, _accountPatternsSource);
	}

	public DaoDataModel<AccountPattern> getAccountPatterns() {
		return _accountPatternsSource;
	}

	public AccountPattern getActiveAccountPattern() {
		return _activeAccountPattern;
	}

	public void setActiveAccountPattern(AccountPattern activeAccountPattern) {
		_activeAccountPattern = activeAccountPattern;
	}

	public SimpleSelection getItemSelection() {
		if (_activeAccountPattern == null && _accountPatternsSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeAccountPattern != null && _accountPatternsSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeAccountPattern.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeAccountPattern = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeAccountPattern = _itemSelection.getSingleSelection();
	}

	public void setFirstRowActive() {
		_accountPatternsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeAccountPattern = (AccountPattern) _accountPatternsSource.getRowData();
		selection.addKey(_activeAccountPattern.getModelId());
		_itemSelection.setWrappedSelection(selection);
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId() + "%");
			filters.add(paramFilter);
		}

		if (filter.getSchemeId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("schemeId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getSchemeId().toString());
			filters.add(paramFilter);
		}

	}

	public void search() {
		clearBean();
	}

	private void setBeans() {
		
	}
	
	public void view() {
		curMode = VIEW_MODE;
	}

	public void add() {
		curMode = NEW_MODE;
		newAccountPattern = new AccountPattern();
		newAccountPattern.setSchemeId(getFilter().getSchemeId());
	}

	public void edit() {
		curMode = EDIT_MODE;
		try {
			newAccountPattern = (AccountPattern) _activeAccountPattern.clone();
		} catch (CloneNotSupportedException e) {
			newAccountPattern = _activeAccountPattern;
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newAccountPattern = _acquiringDao.addAccountPattern(userSessionId,
						newAccountPattern, curLang);
				_itemSelection.addNewObjectToList(newAccountPattern);
			} else {
				newAccountPattern = _acquiringDao.modifyAccountPattern(userSessionId,
						newAccountPattern, curLang);
				_accountPatternsSource.replaceObject(_activeAccountPattern, newAccountPattern);
			}
			_activeAccountPattern = newAccountPattern;
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_acquiringDao.removeAccountPattern(userSessionId, _activeAccountPattern);

			_activeAccountPattern = _itemSelection.removeObjectFromList(_activeAccountPattern);
			if (_activeAccountPattern == null) {
				clearBean();
			} else {
				setBeans();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	// ===--- Getters for values from dictionary ---===//
	public ArrayList<SelectItem> getMerchantTypes() {
		return getDictUtils().getArticles(DictNames.MERCHANT_TYPE, true);
	}

	public ArrayList<SelectItem> getTerminalTypes() {
		return getDictUtils().getArticles(DictNames.TERMINAL_TYPE, true);
	}

	public ArrayList<SelectItem> getOperTypes() {
		return getDictUtils().getArticles(DictNames.OPER_TYPE, true);
	}

	public ArrayList<SelectItem> getAccountTypes() {
		return getDictUtils().getArticles(DictNames.ACCOUNT_TYPE, true);
	}

	public ArrayList<SelectItem> getReasons() {
		final String operTypeIssFee = DictNames.OPER_TYPE + "0119";
		final String operTypeAcqFee = DictNames.OPER_TYPE + "0219";
		final String operTypeInstFee = DictNames.OPER_TYPE + "0319";

		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		items.add(new SelectItem("%", FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "any")));

		if (newAccountPattern != null
				&& (operTypeIssFee.equals(newAccountPattern.getOperType())
						|| operTypeAcqFee.equals(newAccountPattern.getOperType()) || operTypeInstFee
						.equals(newAccountPattern.getOperType()))) {
			items.addAll(getDictUtils().getArticles(DictNames.FEE_TYPE, true));
		}
		return items;
	}

	public ArrayList<SelectItem> getSttlTypes() {
		return getDictUtils().getArticles(DictNames.STTL_TYPE, true);
	}

	// ===--- Getters for values from dictionary (END) ---===//

	public void clearBean() {
		_itemSelection.clearSelection();
		_activeAccountPattern = null;
		_accountPatternsSource.flushCache();

		curLang = userLang;
	}

	public AccountPattern getNewAccountPattern() {
		return newAccountPattern;
	}

	public void setNewAccountPattern(AccountPattern newAccountPattern) {
		this.newAccountPattern = newAccountPattern;
	}

	public AccountPattern getFilter() {
		if (filter == null)
			filter = new AccountPattern();
		return filter;
	}

	public void setFilter(AccountPattern filter) {
		this.filter = filter;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		_accountPatternsSource.flushCache();
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
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
}
