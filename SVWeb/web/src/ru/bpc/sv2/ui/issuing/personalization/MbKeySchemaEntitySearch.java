package ru.bpc.sv2.ui.issuing.personalization;

import java.util.ArrayList;

import java.util.HashMap;
import java.util.Map;

import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.issuing.personalization.KeySchemaEntity;
import ru.bpc.sv2.logic.PersonalizationDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbKeySchemaEntitySearch")
public class MbKeySchemaEntitySearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("PERSONALIZATION");

	private PersonalizationDao _personalizationDao = new PersonalizationDao();

	

	private KeySchemaEntity filter;
	private KeySchemaEntity _activeKeySchemaEntity;
	private KeySchemaEntity newKeySchemaEntity;

	private final DaoDataModel<KeySchemaEntity> _keySchemaEntitiesSource;

	private final TableRowSelection<KeySchemaEntity> _itemSelection;
	
	private static String COMPONENT_ID = "mainTable";
	private String tabName;
	private String parentSectionId;

	public MbKeySchemaEntitySearch() {
		

		_keySchemaEntitiesSource = new DaoDataModel<KeySchemaEntity>() {
			@Override
			protected KeySchemaEntity[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new KeySchemaEntity[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _personalizationDao.getKeySchemaEntities(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new KeySchemaEntity[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _personalizationDao.getKeySchemaEntitiesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<KeySchemaEntity>(null, _keySchemaEntitiesSource);
	}

	public DaoDataModel<KeySchemaEntity> getKeySchemaEntities() {
		return _keySchemaEntitiesSource;
	}

	public KeySchemaEntity getActiveKeySchemaEntity() {
		return _activeKeySchemaEntity;
	}

	public void setActiveKeySchemaEntity(KeySchemaEntity activeKeySchemaEntity) {
		_activeKeySchemaEntity = activeKeySchemaEntity;
	}

	public SimpleSelection getItemSelection() {
		if (_activeKeySchemaEntity == null && _keySchemaEntitiesSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeKeySchemaEntity != null && _keySchemaEntitiesSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeKeySchemaEntity.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeKeySchemaEntity = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_keySchemaEntitiesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeKeySchemaEntity = (KeySchemaEntity) _keySchemaEntitiesSource.getRowData();
		selection.addKey(_activeKeySchemaEntity.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeKeySchemaEntity != null) {
			setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeKeySchemaEntity = _itemSelection.getSingleSelection();
		if (_activeKeySchemaEntity != null) {
			setInfo();
		}
	}

	public void setInfo() {
		// MbNameComponentsSearch compSearch =
		// (MbNameComponentsSearch)ManagedBeanWrapper.getManagedBean("MbNameComponentsSearch");
		// NameComponent componentFilter = new NameComponent();
		// componentFilter.setFormatId(_activeFormat.getId());
		// compSearch.setFilter(componentFilter);
		//		
		// NameBaseParam baseParamFilter = new NameBaseParam();
		// baseParamFilter.setEntityType(_activeFormat.getEntityType());
		// compSearch.setBaseParamFilter(baseParamFilter);
		// compSearch.setBaseValues(null);
		// compSearch.search();
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void clearFilter() {
		filter = new KeySchemaEntity();
		clearState();
		searching = false;
	}

	public KeySchemaEntity getFilter() {
		if (filter == null)
			filter = new KeySchemaEntity();
		return filter;
	}

	public void setFilter(KeySchemaEntity filter) {
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

		if (filter.getKeySchemaId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("keySchemaId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getKeySchemaId().toString());
			filters.add(paramFilter);
		}

		if (filter.getEntityType() != null && filter.getEntityType().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getEntityType());
			filters.add(paramFilter);
		}

		if (filter.getKeyType() != null && filter.getKeyType().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("keyType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getKeyType());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newKeySchemaEntity = new KeySchemaEntity();
		newKeySchemaEntity.setKeySchemaId(getFilter().getKeySchemaId());
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newKeySchemaEntity = (KeySchemaEntity) _activeKeySchemaEntity.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newKeySchemaEntity = _activeKeySchemaEntity;
		}
		curMode = EDIT_MODE;
	}

	public void view() {

	}

	public void save() {
		try {
			if (isNewMode()) {
				newKeySchemaEntity = _personalizationDao.addKeySchemaEntity(userSessionId,
						newKeySchemaEntity);
				_itemSelection.addNewObjectToList(newKeySchemaEntity);
			} else if (isEditMode()) {
				newKeySchemaEntity = _personalizationDao.modifyKeySchemaEntity(userSessionId,
						newKeySchemaEntity);
				_keySchemaEntitiesSource.replaceObject(_activeKeySchemaEntity, newKeySchemaEntity);
			}

			_activeKeySchemaEntity = newKeySchemaEntity;
			setInfo();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_personalizationDao.deleteKeySchemaEntity(userSessionId, _activeKeySchemaEntity);

			_activeKeySchemaEntity = _itemSelection.removeObjectFromList(_activeKeySchemaEntity);
			if (_activeKeySchemaEntity == null) {
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

	public KeySchemaEntity getNewKeySchemaEntity() {
		if (newKeySchemaEntity == null) {
			newKeySchemaEntity = new KeySchemaEntity();
		}
		return newKeySchemaEntity;
	}

	public void setNewKeySchemaEntity(KeySchemaEntity newKeySchemaEntity) {
		this.newKeySchemaEntity = newKeySchemaEntity;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeKeySchemaEntity = null;
		_keySchemaEntitiesSource.flushCache();
		curLang = userLang;
	}

	public ArrayList<SelectItem> getKeyTypes() {
		return getDictUtils().getArticles(DictNames.DES_KEY_TYPE, true, false);
	}

	public List<SelectItem> getKeyTypesEdit() {
		Map<String, Object> paramMap = new HashMap<String, Object>();
		if (getNewKeySchemaEntity().getEntityType() != null 
				&& !getNewKeySchemaEntity().getEntityType().equals("")){
			paramMap.put("ENTITY_TYPE", newKeySchemaEntity.getEntityType());
			return getDictUtils().getLov(LovConstants.SEC_DES_KEY_TYPE, paramMap);
		}
		return new ArrayList<SelectItem>(0);
	}

	public List<SelectItem> getEntityTypes() {
		return getDictUtils().getLov(LovConstants.ENTITY_TYPES_FOR_KEY_SCHEMA);
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeKeySchemaEntity.getId().toString());
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
			KeySchemaEntity[] schemaEntities = _personalizationDao.getKeySchemaEntities(
					userSessionId, params);
			if (schemaEntities != null && schemaEntities.length > 0) {
				_activeKeySchemaEntity = schemaEntities[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
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
