package ru.bpc.sv2.ui.accounts;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.accounts.AccountAlgorithm;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbAccountAlgorithms")
public class MbAccountAlgorithms extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ISSUING");

	private static String COMPONENT_ID = "1655:algorithmsTable";

	private AccountsDao _accDao = new AccountsDao();

	private AccountAlgorithm filter;
	private AccountAlgorithm newAlgorithm;
	private AccountAlgorithm detailAlgorithm;
	private MbAccountAlgorithmSteps stepsBean;

	private final DaoDataModel<AccountAlgorithm> _algorithmsSource;
	private final TableRowSelection<AccountAlgorithm> _itemSelection;
	private AccountAlgorithm _activeAlgorithm;

	private String oldLang;
	
	private String tabName;

	public MbAccountAlgorithms() {
		pageLink = "account|selections";
		tabName = "detailsTab";
		stepsBean = (MbAccountAlgorithmSteps) ManagedBeanWrapper
				.getManagedBean("MbAccountAlgorithmSteps");

		_algorithmsSource = new DaoDataModel<AccountAlgorithm>() {
			@Override
			protected AccountAlgorithm[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new AccountAlgorithm[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _accDao.getAccountAlgorithms(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new AccountAlgorithm[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _accDao.getAccountAlgorithmsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<AccountAlgorithm>(null, _algorithmsSource);
	}

	public DaoDataModel<AccountAlgorithm> getAlgorithms() {
		return _algorithmsSource;
	}

	public AccountAlgorithm getActiveAlgorithm() {
		return _activeAlgorithm;
	}

	public void setActiveAlgorithm(AccountAlgorithm activeAlgorithm) {
		_activeAlgorithm = activeAlgorithm;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeAlgorithm == null && _algorithmsSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeAlgorithm != null && _algorithmsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeAlgorithm.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeAlgorithm = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		try {
			_itemSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (_itemSelection.getSingleSelection() != null
					&& !_itemSelection.getSingleSelection().getId().equals(_activeAlgorithm.getId())) {
				changeSelect = true;
			}
			_activeAlgorithm = _itemSelection.getSingleSelection();
			if (_activeAlgorithm != null) {
				setBeans();
				if (changeSelect) {
					detailAlgorithm = (AccountAlgorithm) _activeAlgorithm.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_algorithmsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeAlgorithm = (AccountAlgorithm) _algorithmsSource.getRowData();
		selection.addKey(_activeAlgorithm.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeAlgorithm != null) {
			setBeans();
			detailAlgorithm = (AccountAlgorithm) _activeAlgorithm.clone();
		}
	}

	public void setBeans() {
		stepsBean.setAlgorithmId(_activeAlgorithm.getId());
		stepsBean.search();
	}

	public void search() {
		clearBean();
		searching = true;
	}

	public void clearFilter() {
		clearBean();
		curLang = userLang;
		searching = false;
		filter = new AccountAlgorithm();
	}

	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getStrId() != null && filter.getStrId().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getStrId().trim().replaceAll("[*]", "%").replaceAll("[?]",
					"_"));
			filters.add(paramFilter);
		}

		if (filter.getDescription() != null && filter.getDescription().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("description");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getDescription().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

	}

	public AccountAlgorithm getFilter() {
		if (filter == null) {
			filter = new AccountAlgorithm();
		}
		return filter;
	}

	public void setFilter(AccountAlgorithm filter) {
		this.filter = filter;
	}

	public void add() {
		newAlgorithm = new AccountAlgorithm();
		newAlgorithm.setLang(userLang);
		curLang = newAlgorithm.getLang();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newAlgorithm = (AccountAlgorithm) detailAlgorithm.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isNewMode()) {
				newAlgorithm = _accDao.addAccountAlgorithm(userSessionId, newAlgorithm);
				detailAlgorithm = (AccountAlgorithm) newAlgorithm.clone();
				_itemSelection.addNewObjectToList(newAlgorithm);
			} else {
				newAlgorithm = _accDao.modifyAccountAlgorithm(userSessionId, newAlgorithm);
				detailAlgorithm = (AccountAlgorithm) newAlgorithm.clone();
				if (!userLang.equals(newAlgorithm.getLang())) {
					newAlgorithm = getNodeByLang(_activeAlgorithm.getId(), userLang);
				}
				_algorithmsSource.replaceObject(_activeAlgorithm, newAlgorithm);
			}
			_activeAlgorithm = newAlgorithm;
			setBeans();
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Iss", "acc_algo_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_accDao.deleteAccountAlgorithm(userSessionId, _activeAlgorithm);
			curMode = VIEW_MODE;
			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Iss",
					"acc_algo_deleted", "(ID = " + _activeAlgorithm.getId() + ")"));

			_activeAlgorithm = _itemSelection.removeObjectFromList(_activeAlgorithm);
			if (_activeAlgorithm == null) {
				clearBean();
			} else {
				setBeans();
				detailAlgorithm = (AccountAlgorithm) _activeAlgorithm.clone();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public ArrayList<SelectItem> getAllAccountTypes() {
		return getDictUtils().getArticles(DictNames.ACCOUNT_TYPE, true, false);
	}

	public AccountAlgorithm getNewAlgorithm() {
		return newAlgorithm;
	}

	public void setNewAlgorithm(AccountAlgorithm newAlgorithm) {
		this.newAlgorithm = newAlgorithm;
	}

	public void clearBean() {
		_itemSelection.clearSelection();
		_activeAlgorithm = null;
		detailAlgorithm = null;
		_algorithmsSource.flushCache();
		if (stepsBean != null) {
			stepsBean.fullCleanBean();
		}
	}
	
	public AccountAlgorithm getNodeByLang(Integer id, String lang) {
		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(String.valueOf(id));
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(lang);
		filtersList.add(paramFilter);

		SelectionParams params = new SelectionParams();
		params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));
		try {
			AccountAlgorithm[] algorithms = _accDao.getAccountAlgorithms(userSessionId, params);
			if (algorithms != null && algorithms.length > 0) {
				return algorithms[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailAlgorithm = getNodeByLang(detailAlgorithm.getId(), curLang);
	}

	public void editLanguage(ValueChangeEvent event) {
		oldLang = (String) event.getOldValue();
	}

	public void confirmEditLanguage() {
		curLang = newAlgorithm.getLang();
		AccountAlgorithm tmp = getNodeByLang(newAlgorithm.getId(), newAlgorithm.getLang());
		if (tmp != null) {
			newAlgorithm.setDescription(tmp.getDescription());
		}
	}

	public void cancelEditLanguage() {
		newAlgorithm.setLang(oldLang);
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public AccountAlgorithm getDetailAlgorithm() {
		return detailAlgorithm;
	}

	public void setDetailAlgorithm(AccountAlgorithm detailAlgorithm) {
		this.detailAlgorithm = detailAlgorithm;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		
		if (tabName.equalsIgnoreCase("stepsTab")) {
			MbAccountAlgorithmSteps bean = (MbAccountAlgorithmSteps) ManagedBeanWrapper
					.getManagedBean("MbAccountAlgorithmSteps");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.OPERATION_ACC_ALGORITHM;
	}
}
