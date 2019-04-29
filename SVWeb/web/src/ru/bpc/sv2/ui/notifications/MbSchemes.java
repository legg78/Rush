package ru.bpc.sv2.ui.notifications;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.NotificationsDao;
import ru.bpc.sv2.notifications.Scheme;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbSchemes")
public class MbSchemes extends AbstractBean {
	private static final Logger logger = Logger.getLogger("NOTIFICATION");

	private static String COMPONENT_ID = "1574:schemesTable";

	private NotificationsDao _notificationsDao = new NotificationsDao();

	

	private Scheme filter;
	private Scheme newScheme;
	private Scheme detailScheme;

	private final DaoDataModel<Scheme> _schemeSource;
	private final TableRowSelection<Scheme> _itemSelection;
	private Scheme _activeScheme;
	private String tabName;
	private ArrayList<SelectItem> institutions;

	private boolean disableSchemeType;
	
	public MbSchemes() {
		
		pageLink = "notifications|schemes";
		_schemeSource = new DaoDataModel<Scheme>() {
			@Override
			protected Scheme[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Scheme[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _notificationsDao.getSchemes(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Scheme[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _notificationsDao.getSchemesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Scheme>(null, _schemeSource);
	}

	public DaoDataModel<Scheme> getSchemes() {
		return _schemeSource;
	}

	public Scheme getActiveScheme() {
		return _activeScheme;
	}

	public void setActiveScheme(Scheme activeScheme) {
		_activeScheme = activeScheme;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeScheme == null && _schemeSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeScheme != null && _schemeSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeScheme.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeScheme = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		try {
			_itemSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (_itemSelection.getSingleSelection() != null 
					&& !_itemSelection.getSingleSelection().getId().equals(_activeScheme.getId())) {
				changeSelect = true;
			}
			_activeScheme = _itemSelection.getSingleSelection();
	
			if (_activeScheme != null) {
				setBeans();
				if (changeSelect) {
					detailScheme = (Scheme) _activeScheme.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_schemeSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeScheme = (Scheme) _schemeSource.getRowData();
		selection.addKey(_activeScheme.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeScheme != null) {
			setBeans();
			detailScheme = (Scheme) _activeScheme.clone();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
		MbSchemeEvents events = (MbSchemeEvents) ManagedBeanWrapper
				.getManagedBean("MbSchemeEvents");
		events.setScheme(_activeScheme);
		events.search();
	}

	public void search() {
		clearBean();
		searching = true;
		curLang = userLang;
	}

	public void clearFilter() {
		curLang = userLang;
		filter = null;
		searching = false;
		clearBean();

		MbSchemeEvents events = (MbSchemeEvents) ManagedBeanWrapper
				.getManagedBean("MbSchemeEvents");
		events.fullCleanBean();
	}

	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter;
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId() + "%");
			filters.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}
		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getName().trim().toUpperCase().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public void add() {
		newScheme = new Scheme();
		newScheme.setLang(userLang);
		curLang = newScheme.getLang();
		if (filter.getInstId() != null) {
			newScheme.setInstId(filter.getInstId());
		}
		disableSchemeType = false;
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newScheme = (Scheme) detailScheme.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			newScheme = _activeScheme;
		}
		if (hasEvents()) {
			disableSchemeType = true;
		} else {
			disableSchemeType = false;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_notificationsDao.deleteScheme(userSessionId, _activeScheme);

			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Ntf", "scheme_deleted",
					"(id = " + _activeScheme.getId() + ")");

			_activeScheme = _itemSelection.removeObjectFromList(_activeScheme);
			if (_activeScheme == null) {
				clearBean();
			} else {
				setBeans();
				detailScheme = (Scheme) _activeScheme.clone();
			}

			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newScheme = _notificationsDao.addScheme(userSessionId, newScheme);
				detailScheme = (Scheme) newScheme.clone();
				_itemSelection.addNewObjectToList(newScheme);
			} else {
				newScheme = _notificationsDao.editScheme(userSessionId, newScheme);
				detailScheme = (Scheme) newScheme.clone();
				if (!userLang.equals(newScheme.getLang())) {
					newScheme = getNodeByLang(_activeScheme.getId(), userLang);
				}
				_schemeSource.replaceObject(_activeScheme, newScheme);
			}
			_activeScheme = newScheme;
			setBeans();
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Ntf",
					"scheme_saved"));

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	private boolean hasEvents() {
		Filter[] filters = new Filter[1];
		filters[0] = new Filter();
		filters[0].setElement("schemeId");
		filters[0].setValue(_activeScheme.getId().toString());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);

		try {
			if (_notificationsDao.getSchemeEventsCount(userSessionId, params) > 0) {
				return true;
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return true;
		}

		return false;
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public Scheme getFilter() {
		if (filter == null) {
			filter = new Scheme();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(Scheme filter) {
		this.filter = filter;
	}

	public Scheme getNewScheme() {
		if (newScheme == null) {
			newScheme = new Scheme();
		}
		return newScheme;
	}

	public void setNewScheme(Scheme newScheme) {
		this.newScheme = newScheme;
	}

	public void clearBean() {
		_schemeSource.flushCache();
		_itemSelection.clearSelection();
		_activeScheme = null;
		detailScheme = null;
		// clear dependent bean
		MbSchemeEvents events = (MbSchemeEvents) ManagedBeanWrapper
				.getManagedBean("MbSchemeEvents");
		events.clearBean();
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		
		if (tabName.equalsIgnoreCase("eventsTab")) {
			MbSchemeEvents bean = (MbSchemeEvents) ManagedBeanWrapper
					.getManagedBean("MbSchemeEvents");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.CONFIGURATION_NOTIF_SCHEME;
	}

	public void changeLanguage(ValueChangeEvent event) {
		if (_activeScheme != null) {
			curLang = (String) event.getNewValue();
			detailScheme = getNodeByLang(detailScheme.getId(), curLang);
		}
	}
	
	public Scheme getNodeByLang(Integer id, String lang) {
		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(id.toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(lang);
		filtersList.add(paramFilter);

		filters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			Scheme[] devices = _notificationsDao.getSchemes(userSessionId, params);
			if (devices != null && devices.length > 0) {
				return devices[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public ArrayList<SelectItem> getSchemeTypes() {
		return getDictUtils().getArticles(DictNames.SCHEME_TYPE, true);
	}

	public boolean isDisableSchemeType() {
		return disableSchemeType;
	}

	public void setDisableSchemeType(boolean disableSchemeType) {
		this.disableSchemeType = disableSchemeType;
	}
	
	public void confirmEditLanguage() {
		curLang = newScheme.getLang();
		Scheme tmp = getNodeByLang(newScheme.getId(), newScheme.getLang());
		if (tmp != null) {
			newScheme.setName(tmp.getName());
			newScheme.setDescription(tmp.getDescription());
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public Scheme getDetailScheme() {
		return detailScheme;
	}

	public void setDetailScheme(Scheme detailScheme) {
		this.detailScheme = detailScheme;
	}

}
