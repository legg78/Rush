package ru.bpc.sv2.ui.hsm;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.hsm.HsmDevice;
import ru.bpc.sv2.hsm.HsmSelection;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.HsmDao;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.rules.CommunicationConstants;
import ru.bpc.sv2.rules.Modifier;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbHsmSelectionsSearch")
public class MbHsmSelectionsSearch extends AbstractBean {
	private static final long serialVersionUID = -8951675563581087824L;

	private static final Logger logger = Logger.getLogger("COMMUNICATION");

	private static String COMPONENT_ID = "mainTable";

	private HsmDao _hsmDao = new HsmDao();

	private RulesDao _rulesDao = new RulesDao();

	private HsmSelection filter;
	private HsmSelection newHsmSelection;

	private final DaoDataModel<HsmSelection> _hsmSelectionSource;
	private final TableRowSelection<HsmSelection> _itemSelection;
	private HsmSelection _activeHsmSelection;
	private String tabName;
	private String parentSectionId;

	private ArrayList<SelectItem> institutions;
	private boolean isDependent = false;
	private boolean isDeviceEnabled = false;
	
	private HashMap<Integer, HsmDevice> hsmsMap;
	
	public MbHsmSelectionsSearch() {
		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		pageLink = "hsm|selections";
		_hsmSelectionSource = new DaoDataModel<HsmSelection>() {
			private static final long serialVersionUID = 7845915142409640081L;

			@Override
			protected HsmSelection[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new HsmSelection[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _hsmDao.getHsmSelections(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new HsmSelection[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _hsmDao.getHsmSelectionsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<HsmSelection>(null, _hsmSelectionSource);

		if (!menu.isKeepState()) {
			// if user came here from menu, we don't need to select previously
			// selected tab
			clearFilter();
		}
	}

	public DaoDataModel<HsmSelection> getHsmSelections() {
		return _hsmSelectionSource;
	}

	public HsmSelection getActiveHsmSelection() {
		return _activeHsmSelection;
	}

	public void setActiveHsmSelection(HsmSelection activeHsmSelection) {
		_activeHsmSelection = activeHsmSelection;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeHsmSelection == null && _hsmSelectionSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeHsmSelection != null && _hsmSelectionSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeHsmSelection.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeHsmSelection = _itemSelection.getSingleSelection();
				setInfoDepenedOnSeqNum();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeHsmSelection = _itemSelection.getSingleSelection();

		if (_activeHsmSelection != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_hsmSelectionSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeHsmSelection = (HsmSelection) _hsmSelectionSource.getRowData();
		selection.addKey(_activeHsmSelection.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeHsmSelection != null) {
			setBeans();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setInfoDepenedOnSeqNum() {

	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {

	}

	public void search() {
		clearBean();
		searching = true;
	}

	public void clearFilter() {
		curLang = userLang;
		filter = null;
		clearBean();
		searching = false;
	}

	public void setFilters() {
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
			paramFilter.setValue(filter.getId().toString());
			filters.add(paramFilter);
		}

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}

		if (filter.getHsmId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("hsmId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getHsmId().toString());
			filters.add(paramFilter);
		}

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId().toString());
			filters.add(paramFilter);
		}

		if (filter.getDescription() != null && filter.getDescription().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("description");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getDescription().trim().replaceAll("[*]", "%").replaceAll(
					"[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getAction() != null && filter.getAction().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("action");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getAction());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newHsmSelection = new HsmSelection();
		newHsmSelection.setLang(userLang);
		newHsmSelection.setHsmId(getFilter().getHsmId());
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newHsmSelection = (HsmSelection) _activeHsmSelection.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newHsmSelection = _activeHsmSelection;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_hsmDao.removeHsmSelection(userSessionId, _activeHsmSelection);

			if (searching) {
				// refresh page if search is on
				clearBean();
			} else {
				// delete object from active page if search is off
				int index = _hsmSelectionSource.getActivePage().indexOf(_activeHsmSelection);
				_hsmSelectionSource.getActivePage().remove(_activeHsmSelection);
				_itemSelection.clearSelection();

				// if something's left on the page, select item of same index
				if (_hsmSelectionSource.getActivePage().size() > 0) {
					SimpleSelection selection = new SimpleSelection();
					if (_hsmSelectionSource.getActivePage().size() > index) {
						_activeHsmSelection = _hsmSelectionSource.getActivePage().get(index);
					} else {
						_activeHsmSelection = _hsmSelectionSource.getActivePage().get(index - 1);
					}
					selection.addKey(_activeHsmSelection.getModelId());
					_itemSelection.setWrappedSelection(selection);

					setBeans();
				} else {
					clearBean();
				}
			}

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newHsmSelection = _hsmDao.addHsmSelection(userSessionId, newHsmSelection);
				_itemSelection.addNewObjectToList(newHsmSelection);
			} else {
				newHsmSelection = _hsmDao.modifyHsmSelection(userSessionId, newHsmSelection);
				_hsmSelectionSource.replaceObject(_activeHsmSelection, newHsmSelection);
			}
			_activeHsmSelection = newHsmSelection;
			cancel();

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		newHsmSelection = null;
		curMode = VIEW_MODE;
	}

	public HsmSelection getFilter() {
		if (filter == null) {
			filter = new HsmSelection();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(HsmSelection hsmSelectionFilter) {
		this.filter = hsmSelectionFilter;
	}

	public HsmSelection getNewHsmSelection() {
		if (newHsmSelection == null) {
			newHsmSelection = new HsmSelection();
		}
		return newHsmSelection;
	}

	public void setNewHsmSelection(HsmSelection newHsmSelection) {
		this.newHsmSelection = newHsmSelection;
	}

	public List<SelectItem> getActions() {
		return getDictUtils().getLov(LovConstants.HSM_ACTIONS);
	}

	public void clearBean() {
		_hsmSelectionSource.flushCache();
		_itemSelection.clearSelection();
		_activeHsmSelection = null;

		// clear dependent bean

	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void changeLanguageTable(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		_hsmSelectionSource.flushCache();
	}

	public void changeLanguage(ValueChangeEvent event) {
		if (_activeHsmSelection != null) {
			curLang = (String) event.getNewValue();
			List<Filter> filtersList = new ArrayList<Filter>();

			Filter paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(_activeHsmSelection.getId().toString());
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
				HsmSelection[] hsmSelections = _hsmDao.getHsmSelections(userSessionId, params);
				if (hsmSelections != null && hsmSelections.length > 0) {
					_activeHsmSelection = hsmSelections[0];
				}
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		}
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public ArrayList<SelectItem> getHsms() {
		// if (hsms == null) {

		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		try {
			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(-1);

			List<Filter> filtersList = new ArrayList<Filter>();
			Filter paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(userLang);
			filtersList.add(paramFilter);

			params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));

			HsmDevice[] hsmsTmp = _hsmDao.getDevices(userSessionId, params);
			for (HsmDevice hsm: hsmsTmp) {
				items.add(new SelectItem(hsm.getId(), hsm.getDescription()));
			}
			// hsms = items;
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		} finally {
			if (items == null)
				items = new ArrayList<SelectItem>();
		}
		// }
		return items;
	}

	public ArrayList<SelectItem> getHsmsForEdit() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(userLang);
		filters[1] = new Filter();
		filters[1].setElement("isEnabled");
		filters[1].setValue(0);

		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(-1);
		params.setFilters(filters);
		try {
			HsmDevice[] hsms = _hsmDao.getDevices(userSessionId, params);
			ArrayList<SelectItem> items = new ArrayList<SelectItem>(hsms.length);
			hsmsMap = new HashMap<Integer, HsmDevice>(hsms.length);
			for (HsmDevice hsm: hsms) {
				items.add(new SelectItem(hsm.getId(), hsm.getDescription()));
				hsmsMap.put(hsm.getId(), hsm);
			}
			return items;
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}
		
		return new ArrayList<SelectItem>(0);
	}

	public ArrayList<SelectItem> getModifiers() {
		ArrayList<SelectItem> items;
		try {
			items = new ArrayList<SelectItem>();

			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(-1);

			List<Filter> filtersList = new ArrayList<Filter>();
			Filter paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setValue(userLang);
			filtersList.add(paramFilter);

			if (getNewHsmSelection().getInstId() != null) {
				paramFilter = new Filter();
				paramFilter.setElement("instId");
				paramFilter.setValue(getNewHsmSelection().getInstId() + ", "
						+ ApplicationConstants.DEFAULT_INSTITUTION);
				filtersList.add(paramFilter);
			} else {
				paramFilter = new Filter();
				paramFilter.setElement("instId");
				paramFilter.setValue(ApplicationConstants.DEFAULT_INSTITUTION);
				filtersList.add(paramFilter);
			}

			paramFilter = new Filter();
			paramFilter.setElement("scaleType");
			paramFilter.setValue(CommunicationConstants.HSM_SCALE_TYPE);
			filtersList.add(paramFilter);

			params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));
			Modifier[] mods = _rulesDao.getModifiers(userSessionId, params);

			for (Modifier mod: mods) {
				items.add(new SelectItem(mod.getId(), mod.getName()));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
			items = new ArrayList<SelectItem>(0);
		}
		return items;
	}

	public boolean isDependent() {
		return isDependent;
	}

	public void setDependent(boolean isDependent) {
		this.isDependent = isDependent;
	}

	public boolean isDeviceEnabled() {
		return isDeviceEnabled;
	}

	public void setDeviceEnabled(boolean isDeviceEnabled) {
		this.isDeviceEnabled = isDeviceEnabled;
	}
	
	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newHsmSelection.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newHsmSelection.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			HsmSelection[] hsmSelections = _hsmDao.getHsmSelections(userSessionId, params);
			if (hsmSelections != null && hsmSelections.length > 0) {
				newHsmSelection = hsmSelections[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public List<SelectItem> getHsmFirmwares() {
		if (getNewHsmSelection().getHsmId() == null) {
			return new ArrayList<SelectItem>(0);
		}
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("hsm_manufacturer", hsmsMap.get(newHsmSelection.getHsmId()).getManufacturer());
		paramMap.put("model_number", hsmsMap.get(newHsmSelection.getHsmId()).getModelNumber());
		return getDictUtils().getLov(LovConstants.HSM_FIRMWARE, paramMap);
	}

	public String getComponentId() {
		if (parentSectionId != null && tabName != null) {
			return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
		} else {
			return "1473:hsmSelectionsTable";
		}
	}
	
	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}

	public Logger getLogger() {
		return logger;
	}

}
