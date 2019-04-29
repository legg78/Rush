package ru.bpc.sv2.ui.accounts;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.accounts.IsoAccountType;
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

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbIsoAccountTypes")
public class MbIsoAccountTypes extends AbstractBean{
	private static final Logger logger = Logger.getLogger("ACCOUNTING");

	private AccountsDao _accountsDao = new AccountsDao();

	
	private IsoAccountType filter;
	private IsoAccountType newIsoAccountType;

	private ArrayList<SelectItem> institutions;

	private final DaoDataModel<IsoAccountType> _isoAccountTypeSource;
	private final TableRowSelection<IsoAccountType> _itemSelection;
	private IsoAccountType _activeIsoAccountType;

	private String instName;
	
	private static String COMPONENT_ID = "isoTypesTable";
	private String tabName;
	private String parentSectionId;

	public MbIsoAccountTypes() {
		

		_isoAccountTypeSource = new DaoDataModel<IsoAccountType>() {
			@Override
			protected IsoAccountType[] loadDaoData(SelectionParams params) {
				if (!searching)
					return new IsoAccountType[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));

					return _accountsDao.getIsoAccountTypes(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new IsoAccountType[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));

					return _accountsDao.getIsoAccountTypesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<IsoAccountType>(null, _isoAccountTypeSource);
	}

	public DaoDataModel<IsoAccountType> getIsoAccountTypes() {
		return _isoAccountTypeSource;
	}

	public IsoAccountType getActiveIsoAccountType() {
		return _activeIsoAccountType;
	}

	public void setActiveIsoAccountType(IsoAccountType activeIsoAccountType) {
		_activeIsoAccountType = activeIsoAccountType;
	}

	public SimpleSelection getItemSelection() {
		if (_activeIsoAccountType == null && _isoAccountTypeSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeIsoAccountType != null && _isoAccountTypeSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeIsoAccountType.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeIsoAccountType = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_isoAccountTypeSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeIsoAccountType = (IsoAccountType) _isoAccountTypeSource.getRowData();
		selection.addKey(_activeIsoAccountType.getModelId());
		_itemSelection.setWrappedSelection(selection);
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeIsoAccountType = _itemSelection.getSingleSelection();
	}

	public void add() {
		newIsoAccountType = new IsoAccountType();
		newIsoAccountType.setAccountType(getFilter().getAccountType());
		newIsoAccountType.setInstId(getFilter().getInstId());
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newIsoAccountType = (IsoAccountType) _activeIsoAccountType.clone();
		} catch (CloneNotSupportedException e) {
			newIsoAccountType = _activeIsoAccountType;
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isEditMode()) {
				newIsoAccountType = _accountsDao.editIsoAccountType(userSessionId,
						newIsoAccountType);
				_isoAccountTypeSource.replaceObject(_activeIsoAccountType, newIsoAccountType);
			} else {
				newIsoAccountType = _accountsDao
						.addIsoAccountType(userSessionId, newIsoAccountType);
				_itemSelection.addNewObjectToList(newIsoAccountType);
			}
			curMode = VIEW_MODE;
			_activeIsoAccountType = newIsoAccountType;

			FacesUtils.addMessageInfo("ISO account type has been saved.");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_accountsDao.removeIsoAccountType(userSessionId, _activeIsoAccountType);
			curMode = VIEW_MODE;

			String msg = "ISO account type with id = " + _activeIsoAccountType.getId()
					+ " has been deleted.";

			_activeIsoAccountType = _itemSelection.removeObjectFromList(_activeIsoAccountType);
			if (_activeIsoAccountType == null) {
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

		clearBean();
		searching = true;
	}

	private void setBeans() {

	}

	public IsoAccountType getFilter() {
		if (filter == null)
			filter = new IsoAccountType();
		return filter;
	}

	public void setFilter(IsoAccountType filter) {
		this.filter = filter;
	}

	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getAccountType() != null && !filter.getAccountType().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("accountType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getAccountType());
			filters.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}
	}

	public IsoAccountType getNewIsoAccountType() {
		if (newIsoAccountType == null) {
			newIsoAccountType = new IsoAccountType();
		}
		return newIsoAccountType;
	}

	public void setNewIsoAccountType(IsoAccountType newIsoAccountType) {
		this.newIsoAccountType = newIsoAccountType;
	}

	public ArrayList<SelectItem> getIsoTypes() {
		return getDictUtils().getArticles(DictNames.ISO_TYPE, true);
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
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
		_activeIsoAccountType = null;
		_isoAccountTypeSource.flushCache();
	}

	public void fullCleanBean() {
		filter = new IsoAccountType();
		instName = null;
		clearBean();
	}

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
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
