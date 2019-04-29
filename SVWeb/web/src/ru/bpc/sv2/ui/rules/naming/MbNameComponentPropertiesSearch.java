package ru.bpc.sv2.ui.rules.naming;

import java.util.ArrayList;


import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.rules.naming.ComponentProperty;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbNameComponentPropertiesSearch")
public class MbNameComponentPropertiesSearch extends AbstractBean {
	private static final long serialVersionUID = 1L;
	
	
	private static final Logger logger = Logger.getLogger("RULES");
	
	private RulesDao _rulesDao = new RulesDao();
	
    private ComponentProperty filter;
    private ComponentProperty _activeProperty;
    private ComponentProperty newProperty;
	
	private ArrayList<ComponentProperty> initialProperties;	// to keep initial state
	private ArrayList<ComponentProperty> storedProperties;	// for current work
	private boolean dontSave;
	
    private String backLink;
	private boolean selectMode;
	
	private final DaoDataModel<ComponentProperty> _propertiesSource;

	private final TableRowSelection<ComponentProperty> _itemSelection;

    public MbNameComponentPropertiesSearch() {
		_propertiesSource = new DaoDataModel<ComponentProperty>() {
			private static final long serialVersionUID = 1L;
			
			@Override
			protected ComponentProperty[] loadDaoData(SelectionParams params) {
				try {
					if (!searching || getFilter().getComponentId() == null) {
						return new ComponentProperty[0];
					}
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					
					if (dontSave) {
						// if we don't want to immediately save all changes that 
						// have been done to this fee rates set then we will
						// work with temporary array list which is first 
						// initiated with values from DB. To find changes that were made
						// one more array is created and is not changed (actually 
						// we could read it from DB again but then we would have to 
						// read it from DB :))
						
						if (storedProperties == null) {
							ComponentProperty[] rates = _rulesDao.getNameComponentPropertiesValues( userSessionId, params);
							storedProperties = new ArrayList<ComponentProperty>(rates.length);
							initialProperties = new ArrayList<ComponentProperty>(rates.length);
							for (ComponentProperty rate: rates) {
								storedProperties.add(rate);
								initialProperties.add(rate);
							}
						}
						// TODO: sort
						return (ComponentProperty[]) storedProperties.toArray(new ComponentProperty[storedProperties.size()]);
					}
					return _rulesDao.getNameComponentPropertiesValues( userSessionId, params);
				} catch (DataAccessException ee) {
					FacesUtils.addMessageError(ee);
					logger.error("",ee);
					return new ComponentProperty[0];
				}
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				try {
					if (!searching || getFilter().getComponentId() == null) {
						return 0;
					}
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					
					if (dontSave && storedProperties != null) {
						return storedProperties.size();
					}
					return _rulesDao.getNameComponentPropertiesValuesCount( userSessionId, params);
				} catch (DataAccessException ee) {
					FacesUtils.addMessageError(ee);
					logger.error("",ee);
					return 0;
				}
			}
		};

		_itemSelection = new TableRowSelection<ComponentProperty>( null, _propertiesSource);
    }

    public DaoDataModel<ComponentProperty> getProperties() {
		return _propertiesSource;
	}

	public ComponentProperty getActiveProperty() {
		return _activeProperty;
	}

	public void setActiveProperty(ComponentProperty activeProperty) {
		_activeProperty = activeProperty;
	}

	public SimpleSelection getItemSelection() {
		if (_activeProperty == null && _propertiesSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeProperty != null && _propertiesSource.getRowCount() > 0)
		{
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeProperty.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeProperty = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeProperty = _itemSelection.getSingleSelection();
		if (_activeProperty != null) {
//			setBeans();
		}
	}

	public void setFirstRowActive() {
		_propertiesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeProperty = (ComponentProperty) _propertiesSource.getRowData();
		selection.addKey(_activeProperty.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeProperty != null) {
//			setBeans();
		}
	}

	public void search() {
		clearState();
		searching = true;		
	}
	
	public void clearFilter() {
		filter = new ComponentProperty();
		clearState();
		searching = false;		
	}
	
	public ComponentProperty getFilter() {
		if (filter == null)
			filter = new ComponentProperty();
		return filter;
	}

	public void setFilter(ComponentProperty filter) {
		this.filter = filter;
	}

	private void setFilters() {
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
	
	
		if (filter.getComponentId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("componentId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getComponentId().toString());
			filters.add(paramFilter);
		}
		
		if (filter.getEntityType() != null && filter.getEntityType().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getEntityType());
			filters.add(paramFilter);
		}
		
	}

	public void add() {
		newProperty = new ComponentProperty();
		newProperty.setComponentId(getFilter().getComponentId());
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newProperty = (ComponentProperty) _activeProperty.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("",e);
			newProperty = _activeProperty;
		}
		if (newProperty.getComponentId() == null) {
			newProperty.setComponentId(getFilter().getComponentId());
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			
			if (isNewMode() && dontSave) {
				_activeProperty.setValue(newProperty.getValue());
			} else if (isNewMode() && !dontSave) {
				_rulesDao.syncNameComponentPropertyValue( userSessionId, newProperty);
			} else if (isEditMode() && dontSave) {
				_activeProperty.setValue(newProperty.getValue());
			} else if (isEditMode() && !dontSave) {
				_rulesDao.syncNameComponentPropertyValue( userSessionId, newProperty);
			}			
			
			if (!dontSave) {
				curMode = VIEW_MODE;
				_propertiesSource.flushCache();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
	}

	public void delete() {
		try {
			if (dontSave) {
				_activeProperty.setValue("");
			} else {
				_rulesDao.deleteNameComponentPropertyValue( userSessionId, _activeProperty);
				_propertiesSource.flushCache();
			}
			curMode = VIEW_MODE;
			
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public void setCurMode(int mode) {
		curMode = mode;
	}

	public boolean isViewMode() {
		return curMode == VIEW_MODE;
	}

	public boolean isEditMode() {
		return curMode == EDIT_MODE;
	}

	public boolean isNewMode() {
		return curMode == NEW_MODE;
	}

	public ComponentProperty getNewProperty() {
		if (newProperty == null) {
			newProperty = new ComponentProperty();
		}
		return newProperty;
	}

	public void setNewProperty(ComponentProperty newProperty) {
		this.newProperty = newProperty;
	}

	public boolean isSearching() {
		return searching;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeProperty = null;			
		_propertiesSource.flushCache();
	}

	public ArrayList<SelectItem> getPadTypes() {
		return getDictUtils().getArticles(DictNames.PAD_TYPES, true, false);
	}
	
	public ArrayList<SelectItem> getBaseValueTypes() {
		return getDictUtils().getArticles(DictNames.BASE_VALUE_TYPES, true, false);
	}
	
	public ArrayList<SelectItem> getTransformationTypes() {
		return getDictUtils().getArticles(DictNames.TRANSFORMATION_TYPES, true, false);
	}
	
	
	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public int getRowsNum() {
		return rowsNum;
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}

	public ArrayList<ComponentProperty> getInitialProperties() {
		return initialProperties;
	}

	public void setInitialProperties(ArrayList<ComponentProperty> initialProperties) {
		this.initialProperties = initialProperties;
	}

	public ArrayList<ComponentProperty> getStoredProperties() {
		return storedProperties;
	}

	public void setStoredProperties(ArrayList<ComponentProperty> storedProperties) {
		this.storedProperties = storedProperties;
	}

	public boolean isDontSave() {
		return dontSave;
	}

	public void setDontSave(boolean dontSave) {
		this.dontSave = dontSave;
	}
	
	public void fullCleanBean() {
		storedProperties = null;
		clearState();
	}
}
