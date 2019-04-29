package ru.bpc.sv2.ui.issuing.personalization;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.personalization.BlankType;
import ru.bpc.sv2.logic.NetworkDao;
import ru.bpc.sv2.logic.PersonalizationDao;
import ru.bpc.sv2.net.CardType;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbPersoBlankTypesSearch")
public class MbPersoBlankTypesSearch extends AbstractBean {
	private static final long serialVersionUID = -2733593521056138917L;

	private static final Logger logger = Logger.getLogger("PERSONALIZATION");

	private static String COMPONENT_ID = "1717:blankTypeTable";

	private PersonalizationDao _personalizationDao = new PersonalizationDao();

	private NetworkDao _networkDao = new NetworkDao();

	private BlankType filter;
	private BlankType _activeBlankType;
	private BlankType newBlankType;

	private ArrayList<SelectItem> institutions;
	private ArrayList<SelectItem> cardTypes;

	private final DaoDataModel<BlankType> _blankTypesSource;

	private final TableRowSelection<BlankType> _itemSelection;

	private String oldLang;
	
	public MbPersoBlankTypesSearch() {
		pageLink = "issuing|perso|blankTypes";
		_blankTypesSource = new DaoDataModel<BlankType>() {
			private static final long serialVersionUID = -8550257384158795937L;

			@Override
			protected BlankType[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new BlankType[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _personalizationDao.getBlankTypes(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new BlankType[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _personalizationDao.getBlankTypesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<BlankType>(null, _blankTypesSource);
	}

	public DaoDataModel<BlankType> getBlankTypes() {
		return _blankTypesSource;
	}

	public BlankType getActiveBlankType() {
		return _activeBlankType;
	}

	public void setActiveBlankType(BlankType activeBlankType) {
		_activeBlankType = activeBlankType;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeBlankType == null && _blankTypesSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeBlankType != null && _blankTypesSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeBlankType.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeBlankType = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_blankTypesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeBlankType = (BlankType) _blankTypesSource.getRowData();
		selection.addKey(_activeBlankType.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeBlankType != null) {
			setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeBlankType = _itemSelection.getSingleSelection();
		if (_activeBlankType != null) {
			setInfo();
		}
	}

	public void setInfo() {
		
	}

	public void search() {
		clearState();
		clearBeansStates();
		searching = true;
	}

	public void clearFilter() {
		filter = null;
		clearState();
		searching = false;
	}

	public BlankType getFilter() {
		if (filter == null) {
			filter = new BlankType();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(BlankType filter) {
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
			paramFilter.setValue(filter.getName().trim().replaceAll("[*]", "%").replaceAll("[?]",
					"_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getCardTypeId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("cardTypeId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getCardTypeId().toString());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newBlankType = new BlankType();
		newBlankType.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newBlankType = (BlankType) _activeBlankType.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newBlankType = _activeBlankType;
		}
		curMode = EDIT_MODE;
	}

	public void view() {

	}

	public void save() {
		try {
			if (isNewMode()) {
				newBlankType = _personalizationDao.addBlankType(userSessionId, newBlankType);
				_itemSelection.addNewObjectToList(newBlankType);
			} else if (isEditMode()) {
				newBlankType = _personalizationDao.modifyBlankType(userSessionId, newBlankType);
				_blankTypesSource.replaceObject(_activeBlankType, newBlankType);
			}

			_activeBlankType = newBlankType;
			setInfo();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_personalizationDao.deleteBlankType(userSessionId, _activeBlankType);
			_activeBlankType = _itemSelection.removeObjectFromList(_activeBlankType);
			if (_activeBlankType == null) {
				clearState();
			} else {
				setInfo();
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

	public BlankType getNewBlankType() {
		if (newBlankType == null) {
			newBlankType = new BlankType();
		}
		return newBlankType;
	}

	public void setNewBlankType(BlankType newBlankType) {
		this.newBlankType = newBlankType;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeBlankType = null;
		_blankTypesSource.flushCache();
		curLang = userLang;
		clearBeansStates();
	}

	public void clearBeansStates() {
		MbPersoCardsSearch cardsSearch = (MbPersoCardsSearch) ManagedBeanWrapper
				.getManagedBean("MbPersoCardsSearch");
		cardsSearch.clearState();
		cardsSearch.setFilter(null);
		cardsSearch.setSearching(false);
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeBlankType.getId().toString());
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
			BlankType[] schemas = _personalizationDao.getBlankTypes(userSessionId, params);
			if (schemas != null && schemas.length > 0) {
				_activeBlankType = schemas[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public ArrayList<SelectItem> getCardTypes() {
		if (cardTypes == null) {
			try {
				SelectionParams params = new SelectionParams();
				params.setRowIndexEnd(-1);
	
				List<Filter> filtersList = new ArrayList<Filter>();
				Filter paramFilter = new Filter();
				paramFilter.setElement("lang");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(userLang);
				filtersList.add(paramFilter);
				
				paramFilter = new Filter();
				paramFilter.setElement("isVirtual");
				paramFilter.setValue("0");
				filtersList.add(paramFilter);
	
				params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));
	
				CardType[] types = _networkDao.getCardTypes(userSessionId, params);
				cardTypes = new ArrayList<SelectItem>(types.length);
				for (CardType type : types) {
					String name = type.getName();
					for (int i = 1; i < type.getLevel(); i++) {
						name = " -- " + name;
					}
//					if (type.isLeaf()) {
						cardTypes.add(new SelectItem(type.getId(), type.getId() + " - " + name, type.getId() + " - " + name));
//					} else {
//						SelectItemGroup group = new SelectItemGroup(type.getId() + " - " + name);
//						group.setDisabled(true);
//						cardTypes.add(group);
//					}
				}
			} catch (Exception e) {
				logger.error("", e);				
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			} finally {
				if (cardTypes == null)
					cardTypes = new ArrayList<SelectItem>();
			}
		}
		return cardTypes;
	}

	public void editLanguage(ValueChangeEvent event) {
		oldLang = (String) event.getOldValue();
	}
	
	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newBlankType.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newBlankType.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			BlankType[] items = _personalizationDao.getBlankTypes(userSessionId, params);
			if (items != null && items.length > 0) {
				newBlankType.setName(items[0].getName());
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void cancelEditLanguage() {
		newBlankType.setLang(oldLang);
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

}
