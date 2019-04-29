package ru.bpc.sv2.ui.acquiring;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.acquiring.MCC;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AcquiringDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbMCCs")
public class MbMCCs extends AbstractBean {

	private static final Logger logger = Logger.getLogger("ACQUIRING");

	private static String COMPONENT_ID = "2271:mccsTable";

	private AcquiringDao _acquireDao = new AcquiringDao();

	private MCC filter;

	private final DaoDataModel<MCC> _MCCsSource;
	private final TableRowSelection<MCC> _itemSelection;
	private MCC _activeMCC;
	private MCC newMCC;

	private String oldLang;

	public MbMCCs() {
		pageLink = "common|mcc";
		_MCCsSource = new DaoDataModel<MCC>() {
			@Override
			protected MCC[] loadDaoData(SelectionParams params) {
				if (!isSearching()) {
					return new MCC[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _acquireDao.getMCCs(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new MCC[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching()) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _acquireDao.getMCCsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<MCC>(null, _MCCsSource);
	}

	public DaoDataModel<MCC> getMccs() {
		return _MCCsSource;
	}

	public MCC getActiveMcc() {
		return _activeMCC;
	}

	public void setActiveMcc(MCC activeMCC) {
		_activeMCC = activeMCC;
	}

	public SimpleSelection getItemSelection() {
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeMCC = _itemSelection.getSingleSelection();
	}

	public void search() {
		curLang = userLang;
		clearBean();
		searching = true;
	}

	public void clearBean() {
		_MCCsSource.flushCache();
		_itemSelection.clearSelection();
		_activeMCC = null;
		clearBeansStates();
	}

	public void clearBeansStates() {
		// clear dependent beans
	}

	public void clearFilter() {
		curLang = userLang;
		filter = new MCC();
		searching = false;
	}

	public void setFilters() {
		filters = new ArrayList<Filter>();
		getFilter();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}
		if (filter.getMcc() != null && filter.getMcc().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("mcc");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getMcc());
			filters.add(paramFilter);
		}
		if (filter.getDinersCode() != null && filter.getDinersCode().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("dinersCode");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getDinersCode());
			filters.add(paramFilter);
		}
		if (filter.getMastercardCabType() != null && filter.getMastercardCabType().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("mastercardCabType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getMastercardCabType());
			filters.add(paramFilter);
		}
		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getName().trim()
			        .toUpperCase().replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public MCC getFilter() {
		if (filter == null) {
			filter = new MCC();
		}
		return filter;
	}

	public void setFilter(MCC filter) {
		this.filter = filter;
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public void add() {
		newMCC = new MCC();
		newMCC.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newMCC = (MCC) _activeMCC.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newMCC = _activeMCC;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isEditMode()) {
				newMCC = _acquireDao.modifyMCC(userSessionId, newMCC);
				_MCCsSource.replaceObject(_activeMCC, newMCC);
			} else {
				_acquireDao.addMCC(userSessionId, newMCC);
				_itemSelection.addNewObjectToList(newMCC);
			}
			_activeMCC = newMCC;
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error(e.getMessage(), e);
		}
	}

	public void delete() {
		try {
			_acquireDao.removeMCC(userSessionId, _activeMCC);
			_activeMCC = _itemSelection.removeObjectFromList(_activeMCC);
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error(e.getMessage(), e);
		}
	}

	public MCC getNewMcc() {
		if (newMCC == null) {
			newMCC = new MCC();
		}
		return newMCC;
	}

	public void setNewMcc(MCC newMCC) {
		this.newMCC = newMCC;
	}

	public void changeLanguage(ValueChangeEvent event) {
		if (_activeMCC != null) {
			curLang = (String) event.getNewValue();
			List<Filter> filtersList = new ArrayList<Filter>();

			Filter paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(_activeMCC.getId().toString());
			filtersList.add(paramFilter);

			paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(curLang);
			filtersList.add(paramFilter);

			filters = filtersList;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			try {
				MCC[] items = _acquireDao.getMCCs(userSessionId, params);
				if (items != null && items.length > 0) {
					_activeMCC = items[0];
				}
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		}
	}

	public void editLanguage(ValueChangeEvent event) {
		oldLang = (String) event.getOldValue();
	}

	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newMCC.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newMCC.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			MCC[] items = _acquireDao.getMCCs(userSessionId, params);
			if (items != null && items.length > 0) {
				newMCC.setName(items[0].getName());
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancelEditLanguage() {
		newMCC.setLang(oldLang);
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

}
