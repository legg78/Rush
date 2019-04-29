package ru.bpc.sv2.ui.network.cardtype;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.cmn.CmnStandard;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommunicationDao;
import ru.bpc.sv2.logic.NetworkDao;
import ru.bpc.sv2.net.CardTypeMap;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean(name = "MbCardTypeMapSearch")
public class MbCardTypeMapSearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("NET");

	private static String COMPONENT_ID = "1353:mapTable";

	private NetworkDao _networksDao = new NetworkDao();

	private CommunicationDao _cmnDao = new CommunicationDao();

	

	private CardTypeMap filter;
	private CardTypeMap _activeTypeMap;
	private CardTypeMap newTypeMap;

	private ArrayList<SelectItem> standards;
	private List<SelectItem> cardTypes;
	
	private final DaoDataModel<CardTypeMap> _typeMapsSource;

	private final TableRowSelection<CardTypeMap> _itemSelection;

	public MbCardTypeMapSearch() {
		
		pageLink = "net|cardTypeMaps";
		_typeMapsSource = new DaoDataModel<CardTypeMap>() {
			@Override
			protected CardTypeMap[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new CardTypeMap[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _networksDao.getCardTypeMaps(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new CardTypeMap[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _networksDao.getCardTypeMapsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<CardTypeMap>(null, _typeMapsSource);
	}

	public DaoDataModel<CardTypeMap> getTypeMaps() {
		return _typeMapsSource;
	}

	public CardTypeMap getActiveTypeMap() {
		return _activeTypeMap;
	}

	public void setActiveTypeMap(CardTypeMap activeTypeMap) {
		_activeTypeMap = activeTypeMap;
	}

	public SimpleSelection getItemSelection() {
		if (_activeTypeMap == null && _typeMapsSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeTypeMap != null && _typeMapsSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeTypeMap.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeTypeMap = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_typeMapsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeTypeMap = (CardTypeMap) _typeMapsSource.getRowData();
		selection.addKey(_activeTypeMap.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeTypeMap != null) {
			// setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeTypeMap = _itemSelection.getSingleSelection();
		if (_activeTypeMap != null) {
			// setInfo();
		}
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void clearFilter() {
		filter = new CardTypeMap();
		clearState();
		searching = false;
	}

	public CardTypeMap getFilter() {
		if (filter == null)
			filter = new CardTypeMap();
		return filter;
	}

	public void setFilter(CardTypeMap filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId() + "%");
			filters.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getCardTypeId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("cardTypeId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getCardTypeId().toString());
			filters.add(paramFilter);
		}

		if (filter.getStandardId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("standardId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getStandardId().toString());
			filters.add(paramFilter);
		}

		if (filter.getNetworkCardType() != null && filter.getNetworkCardType().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("networkCardType");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getNetworkCardType().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newTypeMap = new CardTypeMap();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newTypeMap = (CardTypeMap) _activeTypeMap.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newTypeMap = _activeTypeMap;
		}
		curMode = EDIT_MODE;
	}

	public void view() {

	}

	public void save() {
		try {
			if (isNewMode()) {
				newTypeMap = _networksDao.addCardTypeMap(userSessionId, newTypeMap, userLang);
				_itemSelection.addNewObjectToList(newTypeMap);
			} else if (isEditMode()) {
				newTypeMap = _networksDao.modifyCardTypeMap(userSessionId, newTypeMap, userLang);
				_typeMapsSource.replaceObject(_activeTypeMap, newTypeMap);
			}
			_activeTypeMap = newTypeMap;
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_networksDao.deleteCardTypeMap(userSessionId, _activeTypeMap);
			_activeTypeMap = _itemSelection.removeObjectFromList(_activeTypeMap);

			if (_activeTypeMap == null) {
				clearState();
			}
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public CardTypeMap getNewTypeMap() {
		if (newTypeMap == null) {
			newTypeMap = new CardTypeMap();
		}
		return newTypeMap;
	}

	public void setNewTypeMap(CardTypeMap newTypeMap) {
		this.newTypeMap = newTypeMap;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeTypeMap = null;
		_typeMapsSource.flushCache();
		curLang = userLang;
	}

	public void changeLanguage(ValueChangeEvent event) {

	}

	public List<SelectItem> getCardTypes() {
		if (cardTypes == null) {
			cardTypes = getDictUtils().getLov(LovConstants.CARD_TYPES);			
		}
		return cardTypes;
	}

	public ArrayList<SelectItem> getStandards() {
		if (standards == null) {

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
				CmnStandard[] standardsTmp = _cmnDao.getCommStandards(userSessionId, params);
				for (CmnStandard std : standardsTmp) {
					items.add(new SelectItem(std.getId(), std.getLabel()));
				}
				standards = items;
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			} finally {
				if (standards == null)
					standards = new ArrayList<SelectItem>();
			}
		}
		return standards;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

}
