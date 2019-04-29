package ru.bpc.sv2.ui.administrative.users;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.administrative.roles.Privilege;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.RolesDao;
import ru.bpc.sv2.ui.utils.*;

@ViewScoped
@ManagedBean (name = "MbUserPrivileges")
public class MbUserPrivileges extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");
	
	private RolesDao _rolesDao = new RolesDao();

	private Privilege _activePriv;

	private List<Filter> privFilters;

	private Integer userId;

	private final DaoDataModel<Privilege> _privsSource;

	private final TableRowSelection<Privilege> _itemSelection;

	private static String COMPONENT_ID = "accountsTable";
	private String tabName;
	private String parentSectionId;
	
	public MbUserPrivileges() {

		_privsSource = new DaoDataListAllModel<Privilege>(logger) {
			@Override
			protected List<Privilege> loadDaoListData(SelectionParams params) {
				if (!isSearching() || userId == null) {
					return Collections.EMPTY_LIST;
				}
				searching = false;
				return _rolesDao.getPrivilegesByUserId(userSessionId, userId);
			}
		};

		_itemSelection = new TableRowSelection<Privilege>(null, _privsSource);

	}

	public DaoDataModel<Privilege> getPrivs() {
		return _privsSource;
	}

	public Privilege getActivePriv() {
		return _activePriv;
	}
	public void setActivePriv(Privilege activePriv) {
		this._activePriv = activePriv;
	}

	public SimpleSelection getItemSelection() {
		if (_activePriv == null && _privsSource.getRowCount() > 0) {
			setFirstRowActive();
		}
		else if (_activePriv != null && _privsSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activePriv.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activePriv = _itemSelection.getSingleSelection();			
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activePriv = _itemSelection.getSingleSelection();
	}
	
	public void setFirstRowActive() {
		_privsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activePriv = (Privilege) _privsSource.getRowData();
		selection.addKey(_activePriv.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activePriv != null) {
		
		}
	}

	public void setPrivsFilters() {
		privFilters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("userId");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userId.toString());
		privFilters.add(paramFilter);
	}

	public List<Filter> getPrivFilters() {
		return privFilters;
	}

	public void setPrivFilters(List<Filter> privFilters) {
		this.privFilters = privFilters;
	}
	
	public void search() {
		searching = true;
		_privsSource.flushCache();
		_activePriv = null;
	}

	public Integer getUserId() {
		return userId;
	}

	public void setUserId(Integer userId) {
		this.userId = userId;
	}
	
	public void clearBean() {
		if (_activePriv != null) {
			if (_itemSelection != null) {
				_itemSelection.unselect(_activePriv);
			}
			_activePriv = null;
			_privsSource.flushCache();
		}
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
