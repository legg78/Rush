package ru.bpc.sv2.ui.atm;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.atm.Unsolicited;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.AtmDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbUnsolicitedSearch")
public class MbUnsolicitedSearch extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("ATM");

	private AtmDao _atmDao = new AtmDao();

	private Unsolicited _activeUnsolicited;
	
	private Unsolicited filter;
	private List<Filter> filters;

	private final DaoDataModel<Unsolicited> _dataModel;
	private final TableRowSelection<Unsolicited> _dataSelection;

	private static String COMPONENT_ID = "unsolicitedTable";
	private String tabName;
	private String parentSectionId;
	
	public MbUnsolicitedSearch() {
		_dataModel = new DaoDataModel<Unsolicited>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected Unsolicited[] loadDaoData(SelectionParams params) {
				if (!isSearching())
					return new Unsolicited[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _atmDao.getUnsolicited(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Unsolicited[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching())
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _atmDao.getUnsolicitedCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		_dataSelection = new TableRowSelection<Unsolicited>(null, _dataModel);
	}

	public DaoDataModel<Unsolicited> getDataModel() {
		return _dataModel;
	}

	public Unsolicited getActiveUnsolicited() {
		return _activeUnsolicited;
	}

	public void setActiveunsolicited(Unsolicited activeunsolicited) {
		this._activeUnsolicited = activeunsolicited;
	}

	public SimpleSelection getItemSelection() {
		if (_activeUnsolicited == null && _dataModel.getRowCount() > 0) {
			setFirstRowActive();
		}
		else if (_activeUnsolicited != null && _dataModel.getRowCount() > 0)
		{
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeUnsolicited.getModelId());
			_dataSelection.setWrappedSelection(selection);
			_activeUnsolicited = _dataSelection.getSingleSelection();			
		}
		return _dataSelection.getWrappedSelection();
	}
	
	public void setFirstRowActive() {
		_dataModel.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeUnsolicited = (Unsolicited) _dataModel.getRowData();
		selection.addKey(_activeUnsolicited.getModelId());
		_dataSelection.setWrappedSelection(selection);
		if (_activeUnsolicited != null) {
			setInfo();
		}
	}
	
	public void setInfo() {
		
	}

	public void setItemSelection(SimpleSelection selection) {
		_dataSelection.setWrappedSelection(selection);
		_activeUnsolicited = _dataSelection.getSingleSelection();
		if (_activeUnsolicited != null) {
			setInfo();
		}
	}

	public void search() {
		clearBean();
		searching = true;
	}
	

	public void clearFilter() {
		filter = null;
		clearBean();
	}

	public void clearBean() {
		searching = false;
		curLang = userLang;
		_dataModel.flushCache();
		if (_dataSelection != null) {
			_dataSelection.clearSelection();
		}
		_activeUnsolicited = null;
	}

	public void setFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		
		if (getFilter().getId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getId());
			filtersList.add(paramFilter);
		}
		
		if (getFilter().getTerminalId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("terminalId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getTerminalId());
			filtersList.add(paramFilter);
		}
		if (getFilter().getMessageType() != null && filter.getMessageType()!=null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("messageType");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(getFilter().getMessageType());
			filtersList.add(paramFilter);
		}
		if (getFilter().getDeviceId() != null && filter.getDeviceId()!=null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("deviceId");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(getFilter().getDeviceId());
			filtersList.add(paramFilter);
		}
		if (getFilter().getDeviceStatus() != null && filter.getDeviceStatus().trim().length() > 0) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("deviceStatus");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(getFilter().getDeviceStatus().trim().replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filtersList.add(paramFilter);
		}
		if (getFilter().getErrorSeverity() != null && filter.getErrorSeverity().trim().length() > 0) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("errorSeverity");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(getFilter().getErrorSeverity().trim().replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filtersList.add(paramFilter);
		}
		if (getFilter().getDiagStatus() != null && filter.getDiagStatus().trim().length() > 0) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("diagStatus");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(getFilter().getDiagStatus().trim().replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filtersList.add(paramFilter);
		}
		if (getFilter().getSuppliesStatus() != null && filter.getSuppliesStatus().trim().length() > 0) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("suppliesStatus");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(getFilter().getSuppliesStatus().trim().replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filtersList.add(paramFilter);
		}
		
		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);
		filters = filtersList;
	}

	public Unsolicited getFilter() {
		if (filter == null)
			filter = new Unsolicited();
		return filter;
	}

	public void setFilter(Unsolicited filter) {
		this.filter = filter;
	}

	public List<Filter> getfilters() {
		return filters;
	}

	public void setfilters(List<Filter> filters) {
		this.filters = filters;
	}

	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
	
	public void updateData(){
		_dataModel.flushCache();
	}
	
}
