package ru.bpc.sv2.ui.dashboard;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.WidgetsDao;
import ru.bpc.sv2.ui.administrative.roles.MbPrivileges;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import ru.bpc.sv2.widget.WidgetItem;
import util.auxil.ManagedBeanWrapper;

/**
 * Manage Bean for List Widgets page.
 */
@ViewScoped
@ManagedBean (name = "MbWidgets")
public class MbWidgets extends AbstractBean {
	private static final Logger logger = Logger.getLogger("DASHBOARD");

	private static String COMPONENT_ID = "2123:mainTable";

	private WidgetsDao _widgetDao = new WidgetsDao();
	
	private WidgetItem _activeWidget;
	private WidgetItem newWidget;
	private WidgetItem detailWidget;
	
	private WidgetItem widgetFilter;

	private boolean selectMode;

	private final DaoDataModel<WidgetItem> _widgetsSource;

	private final TableRowSelection<WidgetItem> _widgetSelection;
	
	private String backLink;
	
	private boolean showModal = false;
	
	private boolean _managingNew;
	
	private MbWidgetSess widgetBean;

	public MbWidgets() {
		thisBackLink = "acm_widgets";
		pageLink = "acm|widgets";
		
		widgetBean = (MbWidgetSess) ManagedBeanWrapper.getManagedBean("MbWidgetSess");
		restoreBean = (Boolean) FacesUtils.getSessionMapValue(thisBackLink);
		if (restoreBean == null || !restoreBean) {
			restoreBean = Boolean.FALSE;
		} else {
			_activeWidget = widgetBean.getWidget();
			newWidget = widgetBean.getNewWidget();
			backLink = widgetBean.getBackLink();
			searching = widgetBean.isSearching();
			pageNumber = widgetBean.getPageNum();
			_managingNew = widgetBean.isManagingNew();
			rowsNum = widgetBean.getRowsNum();
			FacesUtils.setSessionMapValue(thisBackLink, Boolean.FALSE);
			
			if (widgetBean.isPrivNeeded()) {
				showModal = true;
				setPrivFromPrivBean();
				widgetBean.setPrivNeeded(false);
			}
		}
		_widgetsSource = new DaoDataModel<WidgetItem>() {
			@Override
			protected WidgetItem[] loadDaoData(SelectionParams params) {
				if (restoreBean) {
					FacesUtils.setSessionMapValue(thisBackLink, Boolean.FALSE);
					if (widgetBean.getWidgetsList() != null) {
						List<WidgetItem> widgetList = widgetBean.getWidgetsList();
						widgetBean.setWidgetsList(null);
						return (WidgetItem[]) widgetList.toArray(new WidgetItem[widgetList.size()]);
					}
				}
				if (!isSearching())
					return new WidgetItem[0];
				try {
					setWidgetsFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _widgetDao.getWidgets(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new WidgetItem[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (restoreBean && widgetBean.getWidgetsList() != null) {
					return widgetBean.getNumberOfWidget();
				}
				if (!isSearching())
					return 0;
				try {
					setWidgetsFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _widgetDao.getWidgetsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		_widgetSelection = new TableRowSelection<WidgetItem>(null, _widgetsSource);
	}

	public DaoDataModel<WidgetItem> getWidgets() {
		return _widgetsSource;
	}

	public WidgetItem getActiveWidget() {
		return _activeWidget;
	}

	public void setActiveWidget(WidgetItem activeWidget) {
		this._activeWidget = activeWidget;
	}

	public SimpleSelection getWidgetSelection() {
		try {
			if (_activeWidget == null && _widgetsSource.getRowCount() > 0) {
				_widgetsSource.setRowIndex(0);
				SimpleSelection selection = new SimpleSelection();
				_activeWidget = (WidgetItem) _widgetsSource.getRowData();
				detailWidget = (WidgetItem) _activeWidget.clone();
				selection.addKey(_activeWidget.getModelId());
				_widgetSelection.setWrappedSelection(selection);
				widgetBean.setWidget(_activeWidget);
			} else if (_activeWidget != null && _widgetsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeWidget.getModelId());
				_widgetSelection.setWrappedSelection(selection);
				_activeWidget = _widgetSelection.getSingleSelection();
				widgetBean.setWidget(_activeWidget);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
		return _widgetSelection.getWrappedSelection();
	}

	public void setWidgetSelection(SimpleSelection selection) {
		try {
			_widgetSelection.setWrappedSelection(selection);
			widgetBean.setWidget(_activeWidget);
			boolean changeSelect = false;
			if (_widgetSelection.getSingleSelection() != null 
					&& !_widgetSelection.getSingleSelection().getId().equals(_activeWidget.getId())) {
				changeSelect = true;
			}
			_activeWidget = _widgetSelection.getSingleSelection();
			if (changeSelect) {
				detailWidget = (WidgetItem) _activeWidget.clone();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
	}

	public void search() {
		clearBean();
		setSearching(true);
	}

	public void clearFilter() {
		widgetFilter = null;
		clearBean();
	}

	public void clearBean() {
		searching = false;
		curLang = userLang;
		_widgetsSource.flushCache();
		if (_widgetSelection != null) {
			_widgetSelection.clearSelection();
		}
		_activeWidget = null;
		detailWidget = null;
	}

	public void add() {
		newWidget = new WidgetItem();
		newWidget.setLang(userLang);
		_managingNew = true;
		curLang = newWidget.getLang();
		curMode = NEW_MODE;
	}
	
	public void edit() {
		try {
			newWidget = (WidgetItem) detailWidget.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		curMode = EDIT_MODE;
		widgetBean.setNewWidget(newWidget);
		widgetBean.setManagingNew(false);

		// may be there ought to be something else?
		// setActiveWidget( _activeWidget );
		widgetBean.setSearching(isSearching());
		_managingNew = false;
	}

	public void save() {
		try {
			if (isEditMode()) {
				newWidget = _widgetDao.editWidget(userSessionId, newWidget);
				detailWidget = (WidgetItem) newWidget.clone();
				if (!userLang.equals(newWidget.getLang())) {
					newWidget = getNodeByLang(_activeWidget.getId(), userLang);
				}
				_widgetsSource.replaceObject(_activeWidget, newWidget);
			} else {
				newWidget = _widgetDao.addWidget(userSessionId, newWidget);
				detailWidget = (WidgetItem) newWidget.clone();
				_widgetSelection.addNewObjectToList(newWidget);
			}
			widgetBean.setPrivNeeded(false);
			_activeWidget = newWidget;
			setShowModal(false);
			FacesUtils.addMessageInfo("Saved!");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);

		}
	}

	public void delete() {
		try {
			_widgetDao.removeWidget(userSessionId, _activeWidget);
			FacesUtils.addMessageInfo("Widget (id = " + _activeWidget.getId()
					+ ") has been deleted.");

			_activeWidget = _widgetSelection.removeObjectFromList(_activeWidget);
			if (_activeWidget == null) {
				clearBean();
			} else {
				detailWidget = (WidgetItem) _activeWidget.clone();
			}
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		
	}

	public void setWidgetsFilters() {
		filters = new ArrayList<Filter>();
		
		Filter paramFilter;
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);
		
		if (getWidgetFilter().getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getWidgetFilter().getId());
			filters.add(paramFilter);
		}
		
		if (getWidgetFilter().getName() != null && !getWidgetFilter().getName().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(getWidgetFilter().getName()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		
	}

	public WidgetItem getWidgetFilter() {
		if (widgetFilter == null)
			widgetFilter = new WidgetItem();
		return widgetFilter;
	}

	public void setWidgetFilter(WidgetItem widgetFilter) {
		this.widgetFilter = widgetFilter;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public WidgetItem getNewWidget() {
		return newWidget;
	}

	public void setNewWidget(WidgetItem newWidget) {
		this.newWidget = newWidget;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public String addPrivs() {
		widgetBean.setPrivNeeded(true);
		widgetBean.setNewWidget(newWidget);
		widgetBean.setWidget(_activeWidget);
		widgetBean.setManagingNew(_managingNew);
		widgetBean.setBackLink(backLink);
		widgetBean.setSearching(searching);
		widgetBean.setPageNum(pageNumber);
		widgetBean.setWidgetsList(_widgetsSource.getActivePage());
		widgetBean.setNumberOfWidget(_widgetsSource.getDataSize());
		
		HashMap<String,Object> queueFilter = new HashMap<String,Object>();
		queueFilter.put("backLink", thisBackLink);
		queueFilter.put("selectMode", "true");
		queueFilter.put("addPrivToRole", "false");
		addFilterToQueue("MbPrivilegesSearch", queueFilter);

		return "acm_privileges";
	}
	
	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}
	
	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailWidget = getNodeByLang(detailWidget.getId(), curLang);
	}
	
	public WidgetItem getNodeByLang(Integer id, String lang) {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(id.toString());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(lang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			WidgetItem[] items = _widgetDao.getWidgets(userSessionId, params);
			if (items != null && items.length > 0) {
				return items[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}
	
	public void confirmEditLanguage() {
		curLang = newWidget.getLang();
		WidgetItem tmp = getNodeByLang(newWidget.getId(), newWidget.getLang());
		if (tmp != null) {
			newWidget.setName(tmp.getName());
			newWidget.setDescription(tmp.getDescription());
		}
	}

	public boolean isShowModal() {
		return showModal;
	}

	public void setShowModal(boolean showModal) {
		this.showModal = showModal;
	}
	
	public void setSearching(boolean searching) {
		this.searching = searching;
		widgetBean.setSearching(searching);
	}

	public void setPageNumber(int pageNumber) {
		this.pageNumber = pageNumber;
		widgetBean.setPageNum(pageNumber);
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
		widgetBean.setRowsNum(rowsNum);
	}
	
	public WidgetItem getDetailWidget() {
		return detailWidget;
	}

	public void setDetailWidget(WidgetItem detailWidget) {
		this.detailWidget = detailWidget;
	}
	
	public boolean isManagingNew() {
		return _managingNew;
	}
	
	public void setManagingNew(boolean _managingNew) {
		this._managingNew = _managingNew;
	}
	
	public void initWidgetPanel(){
		restoreBean = (Boolean) FacesUtils.getSessionMapValue(thisBackLink);
		if (restoreBean == null || !restoreBean) {
			restoreBean = Boolean.FALSE;
		} else {
			_activeWidget = widgetBean.getWidget();
			newWidget = widgetBean.getNewWidget();
			backLink = widgetBean.getBackLink();
			searching = widgetBean.isSearching();
			pageNumber = widgetBean.getPageNum();
			_managingNew = widgetBean.isManagingNew();
			rowsNum = widgetBean.getRowsNum();
			FacesUtils.setSessionMapValue(thisBackLink, Boolean.FALSE);
			if (widgetBean.isPrivNeeded()) {
				showModal = true;
				setPrivFromPrivBean();
				widgetBean.setPrivNeeded(false);
			}
		}
	}
	
	public void setPrivFromPrivBean() {
		MbPrivileges privs = (MbPrivileges) ManagedBeanWrapper.getManagedBean("MbPrivileges");
		if (privs.getPriv().getId() != null) {
			newWidget.setPrivId(privs.getPriv().getId());
			newWidget.setPrivName(privs.getPriv().getName());
		}
	}
	
}
