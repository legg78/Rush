package ru.bpc.sv2.ui.common.arrays;

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

import ru.bpc.sv2.common.arrays.ArrayType;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbArrayTypes")
public class MbArrayTypes extends AbstractBean {

	private static final Logger logger = Logger.getLogger("COMMON");

	private static String COMPONENT_ID = "1904:arrayTypesTable";

	private CommonDao _commonDao = new CommonDao();

	

	private ArrayType filter;
	private ArrayType newArrayType;
	private ArrayType detailArrayType;

	private final DaoDataModel<ArrayType> _arrayTypeSource;
	private final TableRowSelection<ArrayType> _itemSelection;
	private ArrayType _activeArrayType;

	private ArrayList<SelectItem> institutions;
	private String oldLang;
	private ArrayList<SelectItem> dataTypes;
    private ArrayList<SelectItem> scaleTypes;

	public MbArrayTypes() {
		pageLink = "arrays|arrayTypes";
		_arrayTypeSource = new DaoDataModel<ArrayType>() {
			@Override
			protected ArrayType[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new ArrayType[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getArrayTypes(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ArrayType[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getArrayTypesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<ArrayType>(null, _arrayTypeSource);
	}

	public DaoDataModel<ArrayType> getArrayTypes() {
		return _arrayTypeSource;
	}

	public ArrayType getActiveArrayType() {
		return _activeArrayType;
	}

	public void setActiveArrayType(ArrayType activeArrayType) {
		_activeArrayType = activeArrayType;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeArrayType == null && _arrayTypeSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeArrayType != null && _arrayTypeSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeArrayType.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeArrayType = _itemSelection.getSingleSelection();
				setBeans();
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
					&& !_itemSelection.getSingleSelection().getId().equals(_activeArrayType.getId())) {
				changeSelect = true;
			}
			_activeArrayType = _itemSelection.getSingleSelection();
	
			if (_activeArrayType != null) {
				setBeans();
				if (changeSelect) {
					detailArrayType = (ArrayType) _activeArrayType.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_arrayTypeSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeArrayType = (ArrayType) _arrayTypeSource.getRowData();
		selection.addKey(_activeArrayType.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeArrayType != null) {
			setBeans();
			detailArrayType = (ArrayType) _activeArrayType.clone();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
	}

	public void search() {
		curLang = userLang;
		clearBean();
		searching = true;
	}

	public void clearFilter() {
		curLang = userLang;
		filter = new ArrayType();
		searching = false;
	}

	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}
		
		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getName().trim().toUpperCase().replaceAll("[*]", "%")
			        .replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		
		if (filter.getSystemName() != null && filter.getSystemName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("systemName");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getSystemName().trim().toUpperCase().replaceAll("[*]", "%")
			        .replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (filter.getLovId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("lovId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getLovId());
			filters.add(paramFilter);
		}

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newArrayType = new ArrayType();
		newArrayType.setLang(curLang);
		if (dataTypes != null && dataTypes.size() > 0){
			newArrayType.setDataType((String)dataTypes.get(0).getValue());
		}
		curLang = newArrayType.getLang();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newArrayType = (ArrayType) detailArrayType.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_commonDao.deleteArrayType(userSessionId, _activeArrayType);
			_activeArrayType = _itemSelection.removeObjectFromList(_activeArrayType);

			if (_activeArrayType == null) {
				clearBean();
			} else {
				setBeans();
				detailArrayType = (ArrayType) _activeArrayType.clone();
			}
			curMode = VIEW_MODE;
			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
			        "array_type_deleted"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newArrayType = _commonDao.addArrayType(userSessionId, newArrayType);
				detailArrayType = (ArrayType) newArrayType.clone();
				_itemSelection.addNewObjectToList(newArrayType);
			} else {
				newArrayType = _commonDao.editArrayType(userSessionId, newArrayType);
				detailArrayType = (ArrayType) newArrayType.clone();
				if (!userLang.equals(newArrayType.getLang())) {
					newArrayType = getNodeByLang(_activeArrayType.getId(), userLang);
				}
				_arrayTypeSource.replaceObject(_activeArrayType, newArrayType);
			}
			_activeArrayType = newArrayType;

			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
			        "array_type_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public ArrayType getFilter() {
		if (filter == null) {
			filter = new ArrayType();
		}
		return filter;
	}

	public void setFilter(ArrayType filter) {
		this.filter = filter;
	}

	public ArrayType getNewArrayType() {
		if (newArrayType == null) {
			newArrayType = new ArrayType();
		}
		return newArrayType;
	}

	public void setNewArrayType(ArrayType newArrayType) {
		this.newArrayType = newArrayType;
	}

	public void clearBean() {
		_arrayTypeSource.flushCache();
		_itemSelection.clearSelection();
		_activeArrayType = null;
		detailArrayType = null;
	}

	public void changeLanguage(ValueChangeEvent event) {
		if (_activeArrayType != null) {
			curLang = (String) event.getNewValue();
			detailArrayType = getNodeByLang(detailArrayType.getId(), curLang);
		}
	}
	
	public ArrayType getNodeByLang(Integer id, String lang) {
		if (_activeArrayType != null) {
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
				ArrayType[] arrayTypes = _commonDao.getArrayTypes(userSessionId, params);
				if (arrayTypes != null && arrayTypes.length > 0) {
					return arrayTypes[0];
				}
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
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

	public List<SelectItem> getLovs() {
		if (getNewArrayType().getDataType() == null) {
			return new ArrayList<SelectItem>(0);
		}

		Map<String, Object> params = new HashMap<String, Object>(1);
		params.put("DATA_TYPE", getNewArrayType().getDataType());
		return getDictUtils().getLov(LovConstants.LOVS_LOV, params);
	}

	public List<SelectItem> getEntityTypes() {
		return getDictUtils().getLov(LovConstants.ENTITY_TYPES);
	}

	public ArrayList<SelectItem> getDataTypes() {
		if (dataTypes == null){
			dataTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.DATA_TYPES);
		}
		return dataTypes;
	}

    public ArrayList<SelectItem> getScaleTypes() {
        if(scaleTypes == null) {
            scaleTypes = (ArrayList<SelectItem>) getDictUtils().getArticles(DictNames.SCALE_TYPE);
        }
        return scaleTypes;
    }

	public void editLanguage(ValueChangeEvent event) {
		oldLang = (String) event.getOldValue();
	}

	public void confirmEditLanguage() {
		curLang = newArrayType.getLang();
		ArrayType tmp = getNodeByLang(newArrayType.getId(), newArrayType.getLang());
		if (tmp != null) {
			newArrayType.setName(tmp.getName());
			newArrayType.setDescription(tmp.getDescription());
		}
	}

	public void cancelEditLanguage() {
		newArrayType.setLang(oldLang);
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public ArrayType getDetailArrayType() {
		if (detailArrayType == null){
			detailArrayType = new ArrayType();
			detailArrayType.setLang(curLang);
		}
		return detailArrayType;
	}

	public void setDetailArrayType(ArrayType detailArrayType) {
		this.detailArrayType = detailArrayType;
	}
	

}
