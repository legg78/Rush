package ru.bpc.sv2.ui.accounts;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.accounts.BunchType;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbBunchTypes")
public class MbBunchTypes extends AbstractBean {

	private static String COMPONENT_ID = "1042:bunchTypesTable";

	private AccountsDao _accountsDao = new AccountsDao();

	private List<Filter> filters;
	private List<SelectItem> institutions;

	private BunchType filter;
	private BunchType _activeBunchType;
	private BunchType newBunchType;

	private final DaoDataModel<BunchType> _bunchTypeSource;

	private final TableRowSelection<BunchType> _itemSelection;
	private static final Logger logger = Logger.getLogger("ACCOUNTING");
	
	private String tabName;

	public MbBunchTypes() {
		pageLink = "account|entrySets";
		tabName = "templatesTab";
		filters = new ArrayList<Filter>();

		_bunchTypeSource = new DaoDataModel<BunchType>() {
			@Override
			protected BunchType[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new BunchType[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _accountsDao.getBunchTypes(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new BunchType[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _accountsDao.getBunchTypesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<BunchType>(null, _bunchTypeSource);
	}

	public DaoDataModel<BunchType> getBunchTypes() {
		return _bunchTypeSource;
	}

	public BunchType getActiveBunchType() {
		return _activeBunchType;
	}

	public void setActiveBunchType(BunchType activeBunchType) {
		_activeBunchType = activeBunchType;
	}

	public SimpleSelection getItemSelection() {
		if (_activeBunchType == null && _bunchTypeSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeBunchType != null && _bunchTypeSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeBunchType.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeBunchType = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeBunchType = _itemSelection.getSingleSelection();

		// set entry templates
		if (_activeBunchType != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_bunchTypeSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeBunchType = (BunchType) _bunchTypeSource.getRowData();
		selection.addKey(_activeBunchType.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeBunchType != null) {
			setBeans();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
		MbEntryTemplates templatesBean = (MbEntryTemplates) ManagedBeanWrapper
				.getManagedBean("MbEntryTemplates");
		templatesBean.fullCleanBean();
		templatesBean.setBunchTypeId(_activeBunchType.getId());
		templatesBean.setBunchTypeName(_activeBunchType.getName());
		templatesBean.search();
	}

	public void clearFilter() {
		filter = new BunchType();
		curLang = userLang;
		clearBean();

		searching = false;
	}

	public void search() {
		curMode = VIEW_MODE;

		clearBean();
		searching = true;

	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();
		filters.add(Filter.create("lang", userLang));
		if (filter.getId() != null) {
			filters.add(Filter.create("id", filter.getId()));
		}
		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			filters.add(Filter.create("name", Operator.like, Filter.mask(filter.getName())));
		}
		if (filter.getDescription() != null && filter.getDescription().trim().length() > 0) {
			filters.add(Filter.create("name", Operator.like, Filter.mask(filter.getDescription())));
		}
		if (filter.getInstId() != null) {
			filters.add(Filter.create("instId", filter.getInstId()));
		}
	}

	public BunchType getFilter() {
		if (filter == null)
			filter = new BunchType();
		return filter;
	}

	public void setFilter(BunchType filter) {
		this.filter = filter;
	}

	public void add() {
		newBunchType = new BunchType();
		newBunchType.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		newBunchType = (BunchType) _activeBunchType.clone();
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isEditMode()) {
				newBunchType = _accountsDao.editBunchType(userSessionId, newBunchType);
				_bunchTypeSource.replaceObject(_activeBunchType, newBunchType);
			} else {
				newBunchType = _accountsDao.addBunchType(userSessionId, newBunchType);
				_itemSelection.addNewObjectToList(newBunchType);
			}
			curMode = VIEW_MODE;
			_activeBunchType = newBunchType;
			setBeans();
			// TODO: i18n
			FacesUtils.addMessageInfo("Entry set has been saved.");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_accountsDao.removeBunchType(userSessionId, _activeBunchType);
			curMode = VIEW_MODE;
			
			_activeBunchType = _itemSelection.removeObjectFromList(_activeBunchType);
			if (_activeBunchType == null) {
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

	public BunchType getNewBunchType() {
		if (newBunchType == null) {
			newBunchType = new BunchType();
		}
		return newBunchType;
	}

	public void setNewBunchType(BunchType newBunchType) {
		this.newBunchType = newBunchType;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeBunchType.getId().toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);

		SelectionParams params = new SelectionParams();
		params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));
		try {
			BunchType[] bunchTypes = _accountsDao.getBunchTypes(userSessionId, params);
			if (bunchTypes != null && bunchTypes.length > 0) {
				_activeBunchType = bunchTypes[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void clearBean() {
		// clear dependent bean
		MbEntryTemplates templatesBean = (MbEntryTemplates) ManagedBeanWrapper
				.getManagedBean("MbEntryTemplates");
		templatesBean.fullCleanBean();
		templatesBean.setSearching(false);
		
		_itemSelection.clearSelection();
		_activeBunchType = null;
		_bunchTypeSource.flushCache();
	}

	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newBunchType.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newBunchType.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			BunchType[] bunchTypes = _accountsDao.getBunchTypes(userSessionId, params);
			if (bunchTypes != null && bunchTypes.length > 0) {
				newBunchType = bunchTypes[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
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
	}

	public List<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
			if (institutions == null) {
				institutions = new ArrayList<SelectItem>();
			}
		}
		return institutions;
	}
}
