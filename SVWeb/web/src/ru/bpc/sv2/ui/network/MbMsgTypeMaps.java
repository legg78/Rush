package ru.bpc.sv2.ui.network;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommunicationDao;
import ru.bpc.sv2.logic.NetworkDao;
import ru.bpc.sv2.net.MsgTypeMap;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbMsgTypeMaps")
public class MbMsgTypeMaps extends AbstractBean {
	private static final long serialVersionUID = -6076742806121579422L;

	private static final Logger logger = Logger.getLogger("NETWORKS");

	private NetworkDao _networksDao = new NetworkDao();

	private CommunicationDao _cmnDao = new CommunicationDao();
	
	private ArrayList<SelectItem> institutions;

	private MsgTypeMap filter;
	private MsgTypeMap _activeMsgTypeMap;
	private MsgTypeMap newMsgTypeMap;

	private final DaoDataModel<MsgTypeMap> _networkSource;

	private final TableRowSelection<MsgTypeMap> _itemSelection;
	
	private static String COMPONENT_ID = "msgTypeMapsTable";
	private String tabName;
	private String parentSectionId;

	public MbMsgTypeMaps() {
		_networkSource = new DaoDataModel<MsgTypeMap>() {
			private static final long serialVersionUID = -560233456862632673L;

			@Override
			protected MsgTypeMap[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new MsgTypeMap[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _networksDao.getMsgTypeMaps(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new MsgTypeMap[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _networksDao.getMsgTypeMapsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		
		_itemSelection = new TableRowSelection<MsgTypeMap>(null, _networkSource);
	}

	public DaoDataModel<MsgTypeMap> getMsgTypeMaps() {
		return _networkSource;
	}

	public MsgTypeMap getActiveMsgTypeMap() {
		return _activeMsgTypeMap;
	}

	public void setActiveMsgTypeMap(MsgTypeMap activeMsgTypeMap) {
		_activeMsgTypeMap = activeMsgTypeMap;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeMsgTypeMap == null && _networkSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeMsgTypeMap != null && _networkSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeMsgTypeMap.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeMsgTypeMap = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeMsgTypeMap = _itemSelection.getSingleSelection();
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_networkSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeMsgTypeMap = (MsgTypeMap) _networkSource.getRowData();
		selection.addKey(_activeMsgTypeMap.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeMsgTypeMap != null) {
			setBeans();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
	}

	public void clearFilter() {
		filter = null;
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

		if (filter.getId() != null) {
			filters.add(new Filter("id", filter.getId()));
		}
		if (filter.getStandardId() != null) {
			filters.add(new Filter("standardId", filter.getStandardId()));
		}
		if (filter.getNetworkMsgType() != null) {
			filters.add(new Filter("networkMsgType", filter.getNetworkMsgType()));
		}
		if (filter.getMsgType() != null) {
			filters.add(new Filter("msgType", filter.getMsgType()));
		}
	}

	public MsgTypeMap getFilter() {
		if (filter == null) {
			filter = new MsgTypeMap();
		}
		return filter;
	}

	public void setFilter(MsgTypeMap filter) {
		this.filter = filter;
	}

	public void add() {
		newMsgTypeMap = new MsgTypeMap();
		newMsgTypeMap.setStandardId(filter.getStandardId());
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newMsgTypeMap = (MsgTypeMap) _activeMsgTypeMap.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			newMsgTypeMap = _activeMsgTypeMap;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isEditMode()) {
				newMsgTypeMap = _networksDao.modifyMsgTypeMap(userSessionId, newMsgTypeMap);
				_networkSource.replaceObject(_activeMsgTypeMap, newMsgTypeMap);
			} else {
				newMsgTypeMap = _networksDao.addMsgTypeMap(userSessionId, newMsgTypeMap);
				_itemSelection.addNewObjectToList(newMsgTypeMap);
			}

			_activeMsgTypeMap = newMsgTypeMap;
			setBeans();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_networksDao.removeMsgTypeMap(userSessionId, _activeMsgTypeMap);
			curMode = VIEW_MODE;

			_activeMsgTypeMap = _itemSelection.removeObjectFromList(_activeMsgTypeMap);
			if (_activeMsgTypeMap == null) {
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

	public MsgTypeMap getNewMsgTypeMap() {
		if (newMsgTypeMap == null) {
			newMsgTypeMap = new MsgTypeMap();
		}
		return newMsgTypeMap;
	}

	public void setNewMsgTypeMap(MsgTypeMap newMsgTypeMap) {
		this.newMsgTypeMap = newMsgTypeMap;
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}

	public void clearBean() {
		_itemSelection.clearSelection();
		_activeMsgTypeMap = null;
		_networkSource.flushCache();

		clearBeansStates();
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public void clearBeansStates() {
	}

	public String getComponentId() {
		if (parentSectionId != null && tabName != null) {
			return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
		} else {
			return "1231:networksTable";
		}
	}
	
	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}

	public Logger getLogger() {
		return logger;
	}
	
	public List<SelectItem> getMsgTypes() {
		return getDictUtils().getLov(LovConstants.MESSAGE_TYPES);
	}
}
