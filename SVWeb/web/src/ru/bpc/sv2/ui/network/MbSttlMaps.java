package ru.bpc.sv2.ui.network;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.scale.ScaleConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.NetworkDao;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.net.SttlMap;
import ru.bpc.sv2.rules.Modifier;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbSttlMaps")
public class MbSttlMaps extends AbstractBean{
	private static final Logger logger = Logger.getLogger("NETWORKS");

	private static String COMPONENT_ID = "1635:sttlMapsTable";

	private NetworkDao _networksDao = new NetworkDao();

	private RulesDao _rulesDao = new RulesDao();

	

	private SttlMap filter;
	private SttlMap newSttlMap;
	private ArrayList<SelectItem> institutions;
	private ArrayList<SelectItem> networks;
	
	private final DaoDataModel<SttlMap> _actionSource;
	private final TableRowSelection<SttlMap> _itemSelection;
	private SttlMap _activeSttlMap;
	private List<SelectItem> operTypes;
	
	public MbSttlMaps() {
		
		pageLink = "net|sttlMaps";
		_actionSource = new DaoDataModel<SttlMap>() {
			@Override
			protected SttlMap[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new SttlMap[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _networksDao.getSttlMaps(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new SttlMap[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _networksDao.getSttlMapsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<SttlMap>(null, _actionSource);
	}

	public DaoDataModel<SttlMap> getSttlMaps() {
		return _actionSource;
	}

	public SttlMap getActiveSttlMap() {
		return _activeSttlMap;
	}

	public void setActiveSttlMap(SttlMap activeSttlMap) {
		_activeSttlMap = activeSttlMap;
	}

	public SimpleSelection getItemSelection() {
		if (_activeSttlMap == null && _actionSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeSttlMap != null && _actionSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeSttlMap.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeSttlMap = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeSttlMap = _itemSelection.getSingleSelection();
		if (_activeSttlMap != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_actionSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeSttlMap = (SttlMap) _actionSource.getRowData();
		selection.addKey(_activeSttlMap.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeSttlMap != null) {
			setBeans();
		}
	}

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

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getId().toString());
			filters.add(paramFilter);
		}

		if (filter.getSttlType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("sttlType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getSttlType());
			filters.add(paramFilter);
		}

		if (filter.getModId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("modId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getModId().toString());
			filters.add(paramFilter);
		}
	}

	public SttlMap getFilter() {
		if (filter == null) {
			filter = new SttlMap();
		}
		return filter;
	}

	public void setFilter(SttlMap filter) {
		this.filter = filter;
	}

	public void add() {
		newSttlMap = new SttlMap();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newSttlMap = (SttlMap) _activeSttlMap.clone();
		} catch (CloneNotSupportedException e) {
			newSttlMap = _activeSttlMap;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isNewMode()) {
				newSttlMap = _networksDao.addSttlMap(userSessionId, newSttlMap);
				_itemSelection.addNewObjectToList(newSttlMap);
			} else {
				newSttlMap = _networksDao.editSttlMap(userSessionId, newSttlMap);
				_actionSource.replaceObject(_activeSttlMap, newSttlMap);
			}
			_activeSttlMap = newSttlMap;
			curMode = VIEW_MODE;
			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Net",
					"sttl_map_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_networksDao.deleteSttlMap(userSessionId, _activeSttlMap);
			curMode = VIEW_MODE;
			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Net",
					"sttl_map_deleted"));

			_activeSttlMap = _itemSelection.removeObjectFromList(_activeSttlMap);
			if (_activeSttlMap == null) {
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

	public ArrayList<SelectItem> getAllAccountTypes() {
		return getDictUtils().getArticles(DictNames.ACCOUNT_TYPE, true, false);
	}

	public SttlMap getNewSttlMap() {
		return newSttlMap;
	}

	public void setNewSttlMap(SttlMap newSttlMap) {
		this.newSttlMap = newSttlMap;
	}

	public void clearBean() {
		_itemSelection.clearSelection();
		_activeSttlMap = null;
		_actionSource.flushCache();
	}

	public ArrayList<SelectItem> getModifiers() {
		ArrayList<SelectItem> items = null;

		try {
			Modifier[] mods = _rulesDao.getModifiersByScaleType(userSessionId,
					ScaleConstants.STTL_TYPE_SCALE);
			items = new ArrayList<SelectItem>(mods.length);
			for (Modifier mod : mods) {
				items.add(new SelectItem(mod.getId(), mod.getName()));
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			items = new ArrayList<SelectItem>(0);
		}
		return items;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public ArrayList<SelectItem> getNetworks() {
		if (networks == null) {
			networks = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.NETWORKS_SYS);
		}
		if (networks == null)
			networks = new ArrayList<SelectItem>();
		return networks;
	}

	public ArrayList<SelectItem> getSttlTypes() {
		return getDictUtils().getArticles(DictNames.STTL_TYPE, true);
	}

	public List<SelectItem> getMatchStatuses() {
		return getDictUtils().getLov(LovConstants.MATCH_FLAGS);
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public List<SelectItem> getOperTypes() {
		if (operTypes == null) {
			operTypes = getDictUtils().getLov(LovConstants.OPERATION_TYPE);
		}
		return operTypes;
	}

}
